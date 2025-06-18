function [X,p] = allocateAndPay(b,D,config)
    mech = lower(config.mechanism.allocation); % gets it from runsimulation
    expn = config.mechanism.allocParams.exponent;
    
    switch mech
      case 'proportionaldrf' 
          [xs,~]=mech_proportionalDRF(b,D,expn); X=xs.*D;
      case 'conflictdrf'
        %c=config.mechanism.allocParams.c;
        [xs,~]= mech_conflictDRF(b,D,expn);X=xs.*D;
      case 'ssvcg'
        [X, pSSVCG] = mech_ssvcg_vcgPayments(D, b);
        case 'greedy'
          xs = mech_greedy(b,D); X=xs.*D;
      otherwise, error('Unknown allocation');
    end
    pay=lower(config.mechanism.payment);
    switch pay
      case 'payyourbid', p=b;
        case 'ssvcg', p=pSSVCG;
        case 'payyourbid_ifallocated', b = b(:);p=b.*(xs>0);
      otherwise, error('Unknown payment');
    end
    p = p(:);
end