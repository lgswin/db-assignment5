import pandas as pd

# 파일 읽기
# df = pd.read_csv('/data/olist_order_reviews_dataset.csv')
df = pd.read_csv('/Users/gslee/Documents/Conestoga2/33_DatabaseAutomation/assignment5-1/data/olist_order_reviews_dataset.csv')

# 모든 object 타입 문자열을 따옴표로 감싸도록 csv 저장
df.to_csv('olist_order_reviews_clean.csv', index=False, quoting=1)