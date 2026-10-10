import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('ecommerce_sales_customer_analytics_150k.csv')

plt.figure(figsize=(10, 6))
sns.countplot(x='sales_channel', hue='is_repeat_customer', data=df, palette='Set1')
plt.title('Соотношение новых и повторных покупателей по каналам', fontsize=14, fontweight='bold')
plt.xlabel('Канал продаж', fontsize=12)
plt.ylabel('Количество заказов', fontsize=12)
plt.legend(title='Повторный клиент')
plt.tight_layout()
plt.show()
