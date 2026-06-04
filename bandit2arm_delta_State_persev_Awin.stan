
// State-level learning with win-learning rate, and trial level perseveration
//        Model reported in Figure 4.
//    Fit parameters:
//        iterations = 2000, warmup = 1000, chains = 4, cores = 4
//    Data input:
//        Trial level response data with skipped trials excluded
//

data {
  int<lower=1> N;                        // total number subjects
  int<lower=1> T;                       // max number of trials for all subjects
  int<lower=1, upper=T> Tsubj[N];       // number of trials for each subject
  int<lower=-1, upper=2> choice[N, T];
  real outcome[N, T];  // no lower and upper bounds
  int<lower=-1, upper=6> state[N,T];
}
transformed data {
  vector[2] initV;  // initial values for EV
  initV = rep_vector(0.0, 2);
}
parameters {
// Declare all parameters as vectors for vectorizing
  // Hyper(group)-parameters
  vector[3] mu_pr;      // declare a vector of length 2, named 'mu_pr'
  vector<lower=0>[3] sigma;

  // Subject-level raw parameters (for Matt trick)
  vector[N] A_win_pr;    // learning rate
  //vector[N] A_lose_pr;
  vector[N] tau_pr;  // inverse temperature
  vector[N] p_pr;
}
transformed parameters {
  // subject-level parameters
  vector<lower=0, upper=1>[N] A_win;
  //vector<lower=0, upper=1>[N] A_lose;
  //vector<lower=0, upper=5>[N] tau;
  vector<lower=0>[N] tau;
  vector[N] p;

  for (i in 1:N) {
    A_win[i]   = Phi_approx(mu_pr[1]  + sigma[1]  * A_win_pr[i]);             // this is where we set our bounds
    //A_lose[i]   = Phi_approx(mu_pr[2]  + sigma[2]  * A_lose_pr[i]);
    //tau[i] = Phi_approx(mu_pr[2] + sigma[2] * tau_pr[i]) * 5;
    tau[i] = exp(mu_pr[2] + sigma[2] * tau_pr[i]);
    p[i] =       mu_pr[3] + sigma[3] * p_pr[i];
  }
}
model {
  // Hyperparameters
  mu_pr  ~ normal(0, 1);
  sigma ~ normal(0, 0.2);

  // individual parameters
  A_win_pr   ~ normal(0, 1);
  //A_lose_pr   ~ normal(0, 1);
  tau_pr ~ normal(0, 1);
  p_pr   ~ normal(0, 1);

  // Subject loop
  for (i in 1:N) {                  
    vector[2] ev[6];         // declare 'ev' as 6 vectors of length 2 (e.g. ev[1]= Q11,Q12)
    real PE;                 // prediction error
    int prev_action_obs = 0;
    
    // initialize first Q vals with 0s
    for (s in 1:6) ev[s] = initV;

    // initialize previous action
    
    
    // Trial loop
    for (t in 1:(Tsubj[i])) {
      // get current state and action
      int this_state = state[i, t];             // get ith subject, t-th trial
      int action = choice[i, t];
      real this_outcome = outcome[i,t];
      
      vector[2] softmax_input = tau[i] * ev[this_state];
      if (prev_action_obs > 0) {
        softmax_input[prev_action_obs] += p[i];   // boost last chosen action
      }
      
      // compute action probabilities
      action ~ categorical_logit(softmax_input);  // beta, and Q value for both doors, for this state ..
                                                            
      // prediction error
      PE = outcome[i, t] - ev[this_state][action];

      // value updating (learning)
      if (this_outcome >= 0.5) {
        ev[this_state][action] += A_win[i] * PE;
      } 
      
      // update prev observed action
      prev_action_obs = action;
    }
  }
}
generated quantities {
  // For group level parameters
  real<lower=0, upper=1> mu_A_win;
  //real<lower=0, upper=1> mu_A_lose;
  //real<lower=0, upper=5> mu_tau;
  real<lower=0> mu_tau;
  real mu_p;

  // For log likelihood calculation
  real log_lik[N];

  // For posterior predictive check
  real y_pred[N, T];

  // Set all posterior predictions to 0 (avoids NULL values)
  for (i in 1:N) {
    for (t in 1:T) {
      y_pred[i, t] = -1;
    }
  }

  mu_A_win   = Phi_approx(mu_pr[1]);
  //mu_A_lose   = Phi_approx(mu_pr[2]);
  //mu_tau = Phi_approx(mu_pr[2]) * 5;
  mu_tau = exp(mu_pr[2]);
  mu_p = mu_pr[3];

  { // local section, this saves time and space
    for (i in 1:N) {
      vector[2] ev[6]; // expected value
      real PE;      // prediction error
      int prev_action_sim = 0;   
      int prev_action_obs = 0;
      
      // Initialize values
      for (s in 1:6) ev[s] = initV;

      log_lik[i] = 0;

      for (t in 1:(Tsubj[i])) {
        // get current state and action
        int this_state = state[i, t];             // get ith subject, t-th trial
        int action = choice[i, t];
        real this_outcome = outcome[i,t];
        
        vector[2] softmax_input = tau[i] * ev[this_state];
        vector[2] softmax_input_sim;
        int simulated_action;
        
        // for loglike
        if (prev_action_obs > 0) {                       // CHANGE: obs, not sim
          softmax_input[prev_action_obs] += p[i];
        }
        // compute log likelihood of current trial
        //log_lik[i] += categorical_logit_lpmf(choice[i, t] | tau[i] * ev);
        log_lik[i] += categorical_logit_lpmf(action | softmax_input);
        
        // for sim
        
        softmax_input_sim = tau[i] * ev[this_state];
        if (prev_action_sim > 0) {
          softmax_input_sim[prev_action_sim] += p[i];   // boost last chosen action
        }
        // generate posterior prediction for current trial
        //y_pred[i, t] = categorical_rng(softmax(tau[i] * ev));
        
        simulated_action = categorical_logit_rng(softmax_input_sim);
        y_pred[i,t] = simulated_action;
        
        prev_action_sim = simulated_action;
        prev_action_obs = action;

        //y_pred[i, t] = categorical_rng(softmax(softmax_input));

        // prediction error
        //PE = outcome[i, t] - ev[choice[i, t]];
        PE = outcome[i, t] - ev[this_state][action];

        // value updating (learning)
        //ev[choice[i, t]] += A[i] * PE;
        if (this_outcome >= 0.5) {
          ev[this_state][action] += A_win[i] * PE;
        } 
        
      }
    }
  }
}

