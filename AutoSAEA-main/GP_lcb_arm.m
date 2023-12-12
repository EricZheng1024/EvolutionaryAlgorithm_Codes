function [hx, hf, reward, NFEs, CE, gfs] = GP_lcb_arm(ghx, ghf, offspring, hx, hf, FUN, NFEs, CE, gfs)
         
% {GP, LCB}

     try     
         theta =[];
         t_s = [ghx, ghf'];
         D = size(ghx, 2);
         [t_s, ~,~] = unique(t_s, 'rows'); 
         ghx = t_s(:, 1:D);
         ghf = t_s(:, D+1);
         try
            [dmodel,~]=...
             GP_fit(ghx,ghf,@regpoly0,@corrgauss,theta);
         catch
            [dmodel,~]=...
            GP_fit(ghx,ghf,@regpoly0,@corrgauss,theta);
         end
         w = 2; 
         for i = 1 : size(offspring, 1)
             [tempobj,~, MSE,~] =  predictor(offspring(i,:),dmodel); % using the LCB criterion
             OffObj(i) = tempobj - w * sqrt(MSE);                   
         end
         [~,I] = min(OffObj);        
         candidate_position = offspring(I,:);
         [~,ih,~] = intersect(hx,candidate_position,'rows');  
         if isempty(ih)==1
            candidate_fit=FUN(candidate_position); 
            NFEs = NFEs + 1;         
            % save candidate into dataset
            hx=[hx; candidate_position];  hf=[hf, candidate_fit];       % update history database
            
            % update gfs for plotting
            CE(NFEs,:)=[NFEs,candidate_fit];
            gfs(1,NFEs)=min(CE(1:NFEs,2));
            % update the low level arm reward 
            Arm = num2str('GP_lcb ');
            [reward] = Low_level_r(ghf, hf, candidate_fit, NFEs, Arm);
         else
            reward = 0;
         end
     catch
          reward = 0;
     end

end