# Citi Bike 运营分析：需求规律、站点失衡与用户行为差异

## 项目概览

本项目基于 Citi Bike 2024 年 7 月公开骑行数据，构建一张骑行事件级宽表 `trip_base`，围绕城市共享单车运营中的三个问题展开分析：需求高峰、站点车辆失衡、会员与临时用户行为差异。项目同时输出 Python 分析图表、MySQL 复现脚本、Power BI 数据表和本地 Power BI 看板文件。

| 核心指标 | 结果 |
|---|---:|
| 有效骑行订单 | 4,720,941 |
| 日均骑行量 | 152,288 |
| 单日最高骑行量 | 170,957 |
| 最高需求小时 | 17:00 |
| 会员订单占比 | 76.92% |
| 临时用户订单占比 | 23.08% |
| 站点失衡样本订单 | 4,706,967 |
| 全日最大净流出站点 | Broadway & W 56 St（-1,354） |
| 晚高峰最大净流出站点 | E 47 St & Park Ave（-2,790） |

## 业务问题

1. 7 月骑行需求在日期、小时、工作日/周末上有什么规律？
2. 哪些站点持续净流出，可能出现缺车风险？
3. 哪些站点持续净流入，可能出现积车风险？
4. 晚高峰的站点失衡是否比全日口径更突出？
5. 会员和临时用户在骑行时长、时段、车型上有什么差异？
6. 这些发现如何转化为补车、清运和会员转化建议？

## 数据口径

- 数据来源：Citi Bike 公开骑行数据，月份为 2024-07。
- 原始数据中包含少量跨月记录，分析主口径筛选自然月内开始的骑行。
- 清洗后保留骑行时长大于 0 且不超过 24 小时的有效订单，共 4,720,941 条。
- 站点失衡分析要求起点站和终点站字段完整，站点样本共 4,706,967 条。
- `net_inflow = end_rides - start_rides`。数值为负表示净流出，可能对应缺车风险；数值为正表示净流入，可能对应积车风险。
- 数据不包含用户 ID，因此会员/临时用户分析是订单层面的群体差异，不做用户留存或生命周期分析。

## 分析流程

| 模块 | 文件 | 说明 |
|---|---|---|
| 数据概览 | `notebooks/01_data_overview.ipynb` | 查看原始字段、缺失值、时间范围和基础分布 |
| 宽表构建 | `notebooks/02_build_trip_base.ipynb` | 清洗数据并构建日期、小时、时段、时长分组、样本标记等字段 |
| 需求规律 | `notebooks/03_demand_pattern_analysis.ipynb` | 分析日度趋势、小时曲线、工作日/周末差异 |
| 站点失衡 | `notebooks/04_station_imbalance_analysis.ipynb` | 计算全日和晚高峰站点净流入/净流出 |
| 用户差异 | `notebooks/05_member_casual_behavior_analysis.ipynb` | 对比会员与临时用户的时长、时段、车型偏好 |
| BI 数据导出 | `notebooks/06_export_bi_data.ipynb` | 导出 Power BI 所需明细表和聚合表 |
| SQL 复现 | `sql/` | 使用 MySQL 复现核心指标查询 |

## 核心发现

**需求规律**

7 月日均骑行量约 15.23 万，最高日出现在 2024-07-26。小时需求明显集中在傍晚，17:00 是全月订单量最高的小时，18:00 次之，说明晚高峰是调度压力最集中的时段。

![每日骑行需求趋势](outputs/figures/01_daily_ride_demand_trend.png)

工作日呈现通勤型双峰结构，早高峰和晚高峰更明显；周末需求更偏向中午到下午，骑行时长也更长，反映休闲出行占比更高。

![工作日与周末小时需求曲线](outputs/figures/02_hourly_pattern_by_day_type.png)

**站点失衡**

全日口径下，`Broadway & W 56 St`、`W 59 St & 10 Ave`、`Murray St & West St` 等站点净流出较高，可能在高需求时段出现缺车风险。

![Top10 净流出站点](outputs/figures/03_top10_net_outflow_stations.png)

净流入较高的站点包括 `Murray St & Greenwich St`、`11 Ave & W 59 St`、`Old Slip & South St` 等，可能形成积车压力。

![Top10 净流入站点](outputs/figures/04_top10_net_inflow_stations.png)

晚高峰口径下，站点失衡更集中。`E 47 St & Park Ave` 晚高峰净流出达到 -2,790，比全日 Top 站点的绝对净流出更高，说明高峰期调度应单独建模，而不能只看全日平均。

**会员与临时用户差异**

会员订单占 76.92%，是主要使用群体，骑行更短、更稳定，具有通勤属性；临时用户订单占 23.08%，平均骑行时长更长，更偏休闲和游客场景。临时用户中电单车占比更高，适合结合热门休闲站点做转化和定价策略。

![会员与临时用户骑行时长结构](outputs/figures/05_duration_structure_by_member_type.png)

## 业务建议

1. 晚高峰单独设置调度优先级，重点关注 `E 47 St & Park Ave`、`North Moore St & Greenwich St`、`1 Ave & E 68 St` 等净流出站点。
2. 对净流入站点设置清运或容量预警，避免车辆堆积影响还车体验。
3. Power BI 看板中同时保留全日口径和晚高峰口径，避免平均值掩盖高峰风险。
4. 对会员用户重点优化通勤高峰供给，对临时用户重点优化周末、下午、休闲站点和电单车供给。
5. 后续可引入天气、节假日、赛事活动、站点容量和真实库存数据，进一步提升运营建议的可执行性。

## Power BI 与 SQL

Power BI 看板文件位于本地 `outputs/PowerBI/citibike_dashboard.pbix`。

BI 数据表位于 `outputs/bi/`：

| 数据表 | 粒度 | 用途 |
|---|---|---|
| `bi_trip_base_202407.csv` | 一行一次骑行 | Power BI 明细主表，本地使用，不建议上传 |
| `bi_daily_demand_202407.csv` | 一行一天 | 日度趋势 |
| `bi_hourly_demand_202407.csv` | 小时 × 工作日/周末 × 用户类型 | 小时需求结构 |
| `bi_time_period_member_202407.csv` | 时段 × 用户类型 | 时段结构对比 |
| `bi_bike_type_member_202407.csv` | 车型 × 用户类型 | 车型偏好 |
| `bi_station_imbalance_202407.csv` | 一行一个站点 | 全日站点失衡 |
| `bi_evening_station_imbalance_202407.csv` | 一行一个站点 | 晚高峰站点失衡 |

SQL 脚本位于 `sql/`，采用 MySQL 8.0 语法，执行说明见 `sql/README.md`。SQL 部分用于展示从宽表建表、导入、索引到核心指标复现的能力。

## 运行方式

安装依赖：

```bash
pip install -r requirements.txt
```

将 Citi Bike 2024 年 7 月原始压缩包放入 `data_raw/` 后，按顺序运行 `notebooks/01` 到 `notebooks/06`。其中 `02` 会生成清洗后的 `data_clean/trip_base_202407.csv`，`06` 会生成 Power BI 所需数据表。

如果需要使用 SQL 复现指标，先运行 `02_build_trip_base.ipynb` 生成 CSV，再按 `sql/README.md` 的顺序执行脚本。

## 文件结构

```text
citibike-operation-analysis/
├─ data_raw/                 # 原始数据，本地保留
├─ data_clean/               # 清洗后数据，本地保留
├─ notebooks/                # Python 分析流程
├─ outputs/
│  ├─ bi/                    # Power BI 数据表
│  ├─ figures/               # README 展示图表
│  └─ PowerBI/               # 本地 PBIX 文件
├─ sql/                      # MySQL 建表、导入和指标复现脚本
├─ .gitignore
├─ requirements.txt
└─ README.md
```

## 项目局限

- 只分析 2024 年 7 月单月数据，无法覆盖完整季节性。
- 缺少天气、节假日、活动、站点容量、实时库存和调度车辆成本数据。
- 站点失衡使用净流入/净流出作为运营风险代理指标，不等同于真实库存缺车或满桩。
- 数据不含用户 ID，无法分析个人层面的复购、留存或会员转化路径。
- PBIX 和明细 CSV 文件较大，GitHub 展示以 README、notebook、SQL、图表和看板截图为主。
