# SQL复现说明

本目录用于复现 Citi Bike 运营分析项目中的核心指标查询。SQL脚本采用 MySQL 8.0 语法，默认数据库名为 `citibike`，核心表为 `trip_base`。

## 1.准备数据

先运行 notebook 生成清洗后的骑行事件表：

```text
notebooks/02_build_trip_base.ipynb
```

生成后的宽表路径为：

```text
data_clean/trip_base_202407.csv
```

该表粒度为“一行一次骑行事件”。

## 2.创建表并导入CSV

在 MySQL 客户端中执行：

```sql
source sql/00_create_trip_base_table.sql;
```

脚本会创建 `citibike.trip_base` 并通过 `LOAD DATA LOCAL INFILE` 导入本地 CSV。

如果本地 MySQL 禁用了 `LOCAL INFILE`，需要在客户端连接参数和 MySQL 服务端配置中启用后再执行。例如：

```bash
mysql --local-infile=1 -u root -p
```

也可以使用 MySQL Workbench 的 Table Data Import Wizard 导入 `data_clean/trip_base_202407.csv`。

## 3.创建主键和索引

导入完成后执行：

```sql
source sql/01_create_pk_and_indexes.sql;
```

该脚本会基于 `ride_id` 创建主键，并为日期、小时、用户类型、时段和站点字段创建索引，方便后续查询。

## 4.执行分析脚本

建议执行顺序如下：

```text
00_create_trip_base_table.sql
01_create_pk_and_indexes.sql
02_check_trip_base.sql
03__demand_pattern.sql
04__station_imbalance.sql
05__member_casual_behavior.sql
```

各脚本用途：

| SQL文件 | 用途 |
|---|---|
| 00_create_trip_base_table.sql | 创建数据库、建表并导入骑行事件表 |
| 01_create_pk_and_indexes.sql | 创建主键和常用查询索引 |
| 02_check_trip_base.sql | 检查行数、唯一性、时间范围、用户类型、车型和样本标记 |
| 03__demand_pattern.sql | 分析日度、小时、星期、工作日/周末和时段需求 |
| 04__station_imbalance.sql | 构建站点失衡视图，识别缺车和积车风险站点 |
| 05__member_casual_behavior.sql | 分析会员与临时用户在时长、时段、车型和站点上的差异 |

SQL部分主要用于展示关系型数据取数和指标复现能力；完整业务解释、图表和BI数据导出仍以 notebook 与 README 为准。
