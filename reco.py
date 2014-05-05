__author__ = 'Aravindan, Praphull, Vaibhav'

import json
import gc
import numpy as np
from numpy import linalg as LA

def unique_list(seq):
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if x not in seen and not seen_add(x)]

def low_rank_approx(u, s, v, r):
    Ar = np.zeros((len(u), len(v)))
    for i in xrange(r):
        Ar += s[i] * np.outer(u.T[i], v[i])
    return Ar

gc.enable()

'''
jsonarr_users = open("Dataset/yelp_academic_dataset_user.json").readlines()
jsonarr_reviews = open("Dataset/yelp_academic_dataset_review.json").readlines()
jsonarr_business = open("Dataset/yelp_academic_dataset_business.json").readlines()
'''
'''
jsonarr_users = open("Dataset/user_temp.json").readlines()
jsonarr_reviews = open("Dataset/review_temp.json").readlines()
jsonarr_business = open("Dataset/business_temp.json").readlines()
'''

users = []
businesses = []

for jsonstr in open("Dataset/yelp_academic_dataset_user.json").readlines():
    if(jsonstr != ""):
        jsonobj = json.loads(jsonstr)
        users.append(jsonobj["user_id"])

users = unique_list(users)

for jsonstr in open("Dataset/yelp_academic_dataset_business.json").readlines():
    if(jsonstr != ""):
        jsonobj = json.loads(jsonstr)
        businesses.append(jsonobj["business_id"])

businesses = unique_list(businesses)

gc.collect()

print "Test Before Matrix Creation"

rating_matrix = np.zeros((len(users),len(businesses)), dtype=int)

for jsonstr in open("Dataset/yelp_academic_dataset_review.json").readlines():
    if(jsonstr != ""):
        jsonobj = json.loads(jsonstr)
        rating_matrix[users.index(jsonobj["user_id"])][businesses.index(jsonobj["business_id"])] = jsonobj["stars"]

print "Test After Matrix Creation"

gc.collect()

print "Test Before SVD"

u, s, v = LA.svd(rating_matrix, full_matrices=False)

print "Test After SVD"

(m,n) = rating_matrix.shape
W = np.zeros((m, n), dtype=int)
for j in xrange(m):
    W[j] = [1 if z > 0 else 0 for z in rating_matrix[j]]

print "Weight Mtrix Creation Successful"

for i in range(1, min(m,n)-1):
    Ar = low_rank_approx(u, s, v, i)
    EAr = np.dot(W,Ar)
    Er = np.subtract(rating_matrix, EAr)
    FN = LA.norm(Er, 'fro')
    print "FN for rank " + str(i) + " is " + str(FN)
    gc.collect()

