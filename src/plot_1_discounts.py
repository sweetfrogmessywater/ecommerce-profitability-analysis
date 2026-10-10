import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('ecommerce_sales_customer_analytics_150k.csv')
df['profit_status'] = df['profit'].apply(lambda x: 'Loss' if x < 0 else 'Profit')

plt.figure(figsize=(10, 6))
sns.violinplot(x='profit_status', y='discount_amount', data=df, palette='muted')
plt.title('Распределение скидок для прибыльных и убыточных заказов', fontsize=14, fontweight='bold')
plt.xlabel('Статус прибыльности', fontsize=12)
plt.ylabel('Сумма скидки ($)', fontsize=12)
plt.tight_layout()
plt.show()
