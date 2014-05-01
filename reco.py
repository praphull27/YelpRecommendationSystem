__author__ = 'aravind'

import json
import ply
import re
import numpy as np
from numpy import matrix
from numpy import linalg

def unique_list(seq):
    seen = set()
    seen_add = seen.add
    return [ x for x in seq if x not in seen and not seen_add(x)]

def getJsonArray(filename):
    jsonstr = open(filename).read()
    p = re.compile( '}\s * {' )
    jsonstr = p.sub( '}\n{', jsonstr )
    jsonarr = jsonstr.split( '\n' )
    return jsonarr

jsonarr_users = getJsonArray("Dataset/yelp_academic_dataset_user.json")
jsonarr_reviews = getJsonArray("Dataset/yelp_academic_dataset_review.json")
jsonarr_business = getJsonArray("Dataset/yelp_academic_dataset_business.json")

i=0
users = []
businesses = []

for jsonstr in jsonarr_users:
    if(jsonstr != ""):
        jsonobj = json.loads( jsonstr )
        users.append(jsonobj["user_id"])

users = unique_list(users)

for jsonstr in jsonarr_business:
    if(jsonstr != ""):
        jsonobj = json.loads( jsonstr )
        businesses.append(jsonobj["business_id"])

businesses = unique_list(businesses)
user_index_dict = { }
business_index_dict = { }

j=0
for user in users:
    user_index_dict[user] = j
    j = j + 1

j = 0

for business in businesses:
    business_index_dict[business] = j
    j = j + 1


for jsonstr in jsonarr_reviews:
    if(jsonstr != ""):
        i = i+ 1
        jsonobj = json.loads( jsonstr )
        #print json.dumps(jsonobj["user_id"] + "  " + jsonobj["business_id"] + "  counts : " + str(jsonobj["votes"]["funny"] + jsonobj["votes"]["useful"] + jsonobj["votes"]["cool"]))
        #users.append(jsonobj["user_id"])
        #businesses.append(jsonobj["business_id"])
        #print json.dumps(jsonobj)


print(len(users))
print(len(businesses))

matrix_temp = np.zeros((len(users),len(businesses)), dtype=int)
print(matrix_temp[1,1])
print("Number of reviews : "+ str(i))
