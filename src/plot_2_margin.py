import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df = pd.read_csv('ecommerce_sales_customer_analytics_150k.csv')
segment_margin = df.groupby('customer_segment')['profit_margin_percentage'].mean().reset_index()

plt.figure(figsize=(10, 6))
ax = sns.barplot(x='customer_segment', y='profit_margin_percentage', data=segment_margin, palette='crest')

for p in ax.patches:
    ax.annotate(
        f"{p.get_height():.2f}%", 
        (p.get_x() + p.get_width() / 2., p.get_height()), 
        ha='center', va='center', 
        xytext=(0, 8), 
        textcoords='offset points',
        fontsize=11, fontweight='bold'
    )

plt.title('Средняя маржинальность (%) по сегментам клиентов', fontsize=14, fontweight='bold')
plt.xlabel('Клиентский сегмент', fontsize=12)
plt.ylabel('Маржинальность (%)', fontsize=12)
plt.tight_layout()
plt.show()
