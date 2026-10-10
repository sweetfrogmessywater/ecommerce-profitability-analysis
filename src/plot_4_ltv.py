import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('ecommerce_sales_customer_analytics_150k.csv')
segment_ltv = df.groupby('customer_segment')['customer_lifetime_value'].mean().reset_index()

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='customer_segment', y='customer_lifetime_value', data=segment_ltv, palette='viridis')

min_val = segment_ltv['customer_lifetime_value'].min() * 0.95
max_val = segment_ltv['customer_lifetime_value'].max() * 1.05
plt.ylim(min_val, max_val)

for p in ax.patches:
    ax.annotate(
        f"${p.get_height():,.2f}", 
        (p.get_x() + p.get_width() / 2., p.get_height()), 
        ha='center', va='center', 
        xytext=(0, 8), 
        textcoords='offset points',
        fontsize=11, fontweight='bold'
    )

plt.title('Сравнение LTV по сегментам (Детальный масштаб)', fontsize=14, fontweight='bold')
plt.xlabel('Клиентский сегмент', fontsize=12)
plt.ylabel('Средний LTV ($)', fontsize=12)
plt.tight_layout()
plt.show()
