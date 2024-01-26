# ==============================================================================
# Environment
# ==============================================================================
import numpy as np
import pandas as pd
import itertools
from collections import defaultdict
import json
from os import path as path
import statsmodels.api as sm


# ==============================================================================
# Data
# ==============================================================================
data_dir = path.join("..", "..", "data")


## Author contribution
data = pd.read_csv(
    path.join(data_dir, 'Paperid_Remoteness_Authors_Teamroles.csv')
)
data_ = json.loads(data.to_json(orient = 'records'))
data_ = dict(zip(data['paperid'],data_))
PA = {}
for p in data_:
    PA[p] = {}
    PA[p]['Authors'] = list(map(int,data_[p]['authors'].split('&')))
    PA[p]['Remoteness'] = data_[p]['remoteness']
    PA[p]['Contributions'] = {}
    for w in ['conceived','wrote','performed','analyzed']:
        if data_[p][w]:
            PA[p]['Contributions'][w] = list(map(int,data_[p][w].split('&')))
        else:
            PA[p]['Contributions'][w] = []


## whether co-conceiving of the co-authors in terms of their citation impact differences
### To make onsite team and remote team compareable, we focus on team size from 2-8 (representing 74% of papers), 
### the result in Fig. 2b can also be reproduced for teams with full range of team size.
# onsite teams
GO_SC_R = defaultdict(list)
# remote teams
GR_SC_R = defaultdict(list)
# the number of papers with 2 - 8 authors
n = 0
with open(path.join(data_dir, 'Paperid_Year_TeamSize_AuthorCitationCumulative.txt'),'r') as f:
    for line in f:
        line = line.strip('\n').split('\t')
        # paper ID
        p = int(line[0])
        # team size
        ts = int(line[2])
        if ts<=8: ## for team size from 2-8
            n += 1
            # authors and their cumulative citations
            as_ = line[3:]
            # author IDs
            a1 = list(map(int,np.array(as_)[list(range(0,len(as_),2))]))
            # citation counts
            a2 = list(map(int,np.array(as_)[list(range(1,len(as_),2))]))
            # combining author IDs and citation counts into a dictionary
            ac = dict(zip(a1,a2))
            # if everything is fine when parsing and the lengths match up
            if len(ac) == len(a1):
                # get the set of all authors who were behind the conception of the paper
                aus_ = set(PA[p]['Contributions'].get('conceived',[]))
                rs = []
                rs_ = []
                cs = []
                # for all pairs of authors on the paper
                for i,j in itertools.combinations(list(ac.keys()),2):
                    # check if both authors conceived of this paper
                    if i in aus_ and j in aus_:
                        if ac[i] > 0 or ac[j] > 0:## at least one members have citation data
                            # add the absolute difference of the log10 cumulative citation count for this pair of authors
                            rs.append(abs(np.log10(ac[i]+1)-np.log10(ac[j]+1)))
                            # record that the authors co-conceived
                            cs.append(1)        
                    else:
                        if ac[i] > 0 or ac[j] > 0:
                            rs.append(abs(np.log10(ac[i]+1)-np.log10(ac[j]+1)))
                            cs.append(0)
                            
                # record whether the paper was a "remote" paper or not
                if PA[p]['Remoteness']==0:
                    for i in range(len(rs)):
                        GO_SC_R[rs[i]].append(cs[i])
                else:
                    for i in range(len(rs)):
                        GR_SC_R[rs[i]].append(cs[i])



## bin size of citation-difference scale  = 0.5
delta = 0.5
x1 = defaultdict(list)
for i in GO_SC_R:
    x1[int(i/delta)*delta] += GO_SC_R[i]

x2 = defaultdict(list)
for i in GR_SC_R:
    x2[int(i/delta)*delta] += GR_SC_R[i]

x_1 = [i for i in sorted(x1) if i <=4]
y_1 = [np.mean(x1[i]) for i in x_1]

x_2 = [i for i in sorted(x2) if i <=4]
y_2 = [np.mean(x2[i]) for i in x_2]



### regression between citation impact difference and probability of co-conceiving
df = pd.DataFrame()
y_1_all = []
x_1_all = []
y_2_all = []
x_2_all = []

for i in sorted(x1):
    if i <=4:
        x_1_all += [i]*len(x1[i])
        y_1_all += x1[i]

for i in sorted(x2):
    if i <=4:
        x_2_all += [i]*len(x2[i])
        y_2_all += x2[i]

df['y'] = y_1_all
df['x'] = x_1_all
y = df['y'] 
x = df['x']
x = sm.add_constant(x)

#fit (incorrect) linear regression model
model = sm.OLS(y, x).fit()

#view model summary
print(model.summary())


# fit a log-odds model
logit_mod = sm.Logit(y, x)
logit_res = logit_mod.fit()
print(logit_res.summary())


df = pd.DataFrame()
df['y'] = y_2_all
df['x'] = x_2_all
y = df['y'] 
x = df['x']
x = sm.add_constant(x)

#fit linear regression model
model = sm.OLS(y, x).fit()

#view model summary
print(model.summary())

# fit a log-odds model
logit_mod = sm.Logit(y, x)
logit_res = logit_mod.fit()
print(logit_res.summary())
