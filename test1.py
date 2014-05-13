__author__ = 'aravindan'

import json
import gc
import csv

from scipy import linalg as LAS
import numpy as np
from numpy import linalg as LA

def unique_list(seq):
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if x not in seen and not seen_add(x)]


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


reviews = []


rating_matrix = np.zeros((len(users),len(businesses)), dtype=int)

for jsonstr in open("Dataset/yelp_academic_dataset_review.json").readlines():
    if(jsonstr != ""):
        jsonobj = json.loads(jsonstr)
        rating_matrix[users.index(jsonobj["user_id"])][businesses.index(jsonobj["business_id"])] = jsonobj["stars"]

np.savetxt('Data1.csv',rating_matrix, delimiter=",")


gc.collect()
