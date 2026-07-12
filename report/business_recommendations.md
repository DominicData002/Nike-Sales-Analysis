 Nike Sales — Business Recommendations

 Project Context

This analysis is based on a 2,500-row Nike retail sales dataset containing significant data quality issues (missing dates, missing discount values, invalid discounts, negative units, and incomplete revenue records). All findings below are evidence-based and explicitly note the sample size they rely on, in line with the data limitations documented in the `Data Quality` section of the dashboard.



 Key Findings & Recommendations

 1. Missing discount data is strongly linked to the worst-performing orders
**Finding:** Among the 166 orders with complete, trustworthy revenue data, orders with missing/invalid discount values show an average margin of **-74.61%** — dramatically worse than any defined discount band (all of which are profitable, ranging from +15.81% to +40.17%).

**Recommendation:** Treat missing discount data as a data quality/process red flag, not just a gap to fill in later. Investigate the point-of-sale or order capture system for orders where discount wasn't recorded — these orders are disproportionately loss-making, and fixing the root cause of missing data could directly surface and correct margin-destroying transactions.

**Caveat:** Based on 33 orders within the complete-data subset (n=166 of 2,500 total).


 2. Heavier discounts do not appear to hurt margin in this dataset
**Finding:** Contrary to typical retail assumptions, orders with 50%+ discounts show the *highest* average margin (**+40.17%**) among all defined discount bands, ahead of 21-50% (+19.02%) and 1-20% (+15.81%).

**Recommendation:** Do not assume high discounts are automatically eroding profitability — validate this pattern with a larger, more complete dataset before adjusting discount policy. If confirmed at scale, this suggests the product mix or channel behind heavy-discount orders may carry naturally higher base margin, and discount caps may not be the right lever for margin protection.

**Caveat:** Based on only 61 orders (50%+ band); directional, not conclusive given the small sample.


3. Revenue data is unreliable for 93% of orders — this is the most urgent fix
**Finding:** Only 166 of 2,500 orders (6.6%) have complete, trustworthy Revenue and Profit figures. The remaining 2,334 rows have Revenue = 0, primarily due to missing discount values (1,815 rows) or missing Units_Sold/MRP (remaining rows).

**Recommendation:** Prioritize fixing data capture at the source before any revenue-based business decision is made from this dataset. Every revenue/margin insight in this report should be treated as directional, not a reliable basis for pricing or discount strategy, until this is resolved.


 4. Sales volume is diversified — no single product or region dominates
**Finding:** Units sold are fairly evenly spread across product lines (Training: 509, Lifestyle: 502, Soccer: 472, Basketball: 431, Running: 371) and across regions (Mumbai: 436 down to Kolkata: 355). The top 10 products by units are also closely clustered (118–147 units each), with no single "hero" product.

**Recommendation:** Marketing and inventory strategy should avoid over-indexing on any one category — demand is balanced. Focus differentiation efforts (e.g., promotions, bundling) on channel (Online vs Retail) or gender segment rather than product line, where there's more room to shift behavior.


 5. Online channel slightly outperforms Retail
**Finding:** Online channel drove more units sold (1,168) than Retail (1,117), across a comparable number of orders (1,255 vs 1,245).

**Recommendation:** Continue to invest in the online channel's momentum (e.g., site experience, online-exclusive promotions), but the gap is modest — this isn't evidence of a major channel shift, more a mild signal worth monitoring over time as more complete data becomes available.


 6. Return rates are consistent across product lines — not a targeted problem area
**Finding:** Return rates range narrowly from 7.17% (Running) to 8.90% (Soccer) across all product lines — no line stands out as having a disproportionate returns issue relative to its sales volume.

**Recommendation:** No product-line-specific action needed on returns at this time. If return rate becomes a focus area, investigate at the SKU or size level instead, since product-line-level data doesn't show a meaningful pattern.


 Overall Data Quality Summary

Issue                            Rows Affected                     % of Dataset 
Missing Order Date                 616                                 24.6% 
Missing/Invalid Discount Value      1,848                               73.9% 
Incomplete Revenue Records          2,334                            93.4% 
Flagged Returns (negative units in source)  205                          8.2% 

**Bottom line:** This dataset is well-suited for **volume, channel, and product-mix analysis** (based on the full 2,500 rows), but **revenue and margin conclusions should be treated as preliminary** given the small complete-data subset (166 rows). The most valuable near-term action isn't a pricing or discount change — it's fixing data capture so future analysis can be conducted with confidence.
