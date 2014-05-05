__author__ = 'Aravindan, Praphull, Vaibhav'

import json
import ply
import re
import numpy as np
from numpy import matrix
from numpy import linalg as LA

def unique_list(seq):
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if x not in seen and not seen_add(x)]

jsonarr_users = open("Dataset/yelp_academic_dataset_user.json").readlines()
jsonarr_reviews = open("Dataset/yelp_academic_dataset_review.json").readlines()
jsonarr_business = open("Dataset/yelp_academic_dataset_business.json").readlines()

users = []
businesses = []

for jsonstr in jsonarr_users:
    if(jsonstr != ""):
        jsonobj = json.loads(jsonstr)
        users.append(jsonobj["user_id"])

users = unique_list(users)

for jsonstr in jsonarr_business:
    if(jsonstr != ""):
        jsonobj = json.loads( jsonstr )
        businesses.append(jsonobj["business_id"])

businesses = unique_list(businesses)

rating_matrix = np.zeros((len(users),len(businesses)), dtype=int)

for jsonrev in jsonarr_reviews:
    if(jsonrev != ""):
        jsonobj = json.loads(jsonrev)
        rating_matrix[users.index(jsonobj["user_id"])][businesses.index(jsonobj["business_id"])] = jsonobj["stars"]

def low_rank_approx(SVD=None, A=None, r=1):
    if not SVD:
        SVD = LA.svd(A, full_matrices=False)
    u, s, v = SVD
    Ar = np.zeros((len(u), len(v)))
    for i in xrange(r):
        Ar += s[i] * np.outer(u.T[i], v[i])
    return Ar


R = rating_matrix
u, s, v = LA.svd(R, full_matrices=False)
(m,n) = R.shape
W = np.zeros((m, n), dtype=int)
for j in xrange(m):
    W[j] = [1 if z > 0 else 0 for z in R[j]]

for i in range(1, min(m,n)-1):
    Ar = low_rank_approx((u, s, v), r=i)
    EAr = np.dot(W,Ar)
    Er = np.subtract(R, EAr)
    FN = LA.norm(Er, 'fro')
    print "FN for rank " + str(i) + " is " + str(FN) + "\n"
