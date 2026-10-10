import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('ecommerce_sales_customer_analytics_150k.csv')

plt.figure(figsize=(12, 6))
sns.countplot(x='sales_channel', hue='order_status', data=df, palette='Set2')
plt.title('Распределение статусов заказов по каналам продаж', fontsize=14, fontweight='bold')
plt.xlabel('Канал продаж', fontsize=12)
plt.ylabel('Количество заказов', fontsize=12)
plt.legend(title='Статус заказа')
plt.tight_layout()
plt.show()
