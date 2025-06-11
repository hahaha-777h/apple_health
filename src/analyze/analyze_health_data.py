#!/usr/bin/env python3

import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np
import calendar

DB_PATH = "../../db/health_data.db"

try:
	conn = sqlite3.connect(DB_PATH)
	print(f"Success to connect {DB_PATH}")
	
	print("Loading health_dates....")
	df_dates = pd.read_sql_query("SELECT * FROM health_dates", conn)
	print("Finished to load health_dates")
	print("Here are the first five lines")
	print(df_dates.head())
	
	print("Loading health_metrics....")
	df_metrics = pd.read_sql_query("SELECT * FROM health_metrics", conn)
	print("Finished to load health_metrics")
	print("Here are the first five lines")
	print(df_metrics.head())
	
	
	df_combined = pd.merge(df_metrics, df_dates,
						   		left_on="health_date_id", right_on="id",
							 	suffixes=("_metrics", "_dates"))
	print("Here are the first five lines of merged data")
	print(df_combined.head())
	print("Here are the infomation of merged data")
	
	df_combined = df_combined.sort_values(by="record_date").reset_index(drop=True)
	
	
	metrics_to_be_plot = ["step_count", "burned_energy", "flights_climbed", "headphone_volume", "walking_speed", "step_length"]

	df_processed = df_combined.copy()
	df_processed["record_date"] = pd.to_datetime(df_processed["record_date"])
	#Drop invalid data
	
	for col in metrics_to_be_plot:
		first_valid_idx = ((df_processed[col] != 0) & ~df_processed[col].isnull()).idxmax()
		if pd.isna(first_valid_idx):
			print(f"There is no valid data in {col}")
			df_processed[col] = np.nan
		else:
			df_processed.loc[df_processed.index < first_valid_idx, col] = np.nan
			print(f"{col}Valid data start from {df_processed.loc[first_valid_idx, 'record_date']}")
	
	#Histogram
	print("Here is histogram")
	
	plt.figure(figsize=(15, 8))
	for i, col in enumerate(metrics_to_be_plot):
		plt.subplot(2, 3, i + 1)
		sns.histplot(df_processed[col].dropna(), bins=40,  kde=True)
		plt.title(f"{col.replace(',', ' ').title()}")
		plt.xlabel(col.replace("_", " ").title())
		plt.ylabel("Frequency")
	plt.tight_layout()
	# plt.show()



	# Monthly and weekly analysis

	df_processed["day_of_week"] = df_processed["record_date"].dt.day_name()
	df_processed["month"] = df_processed["record_date"].dt.month

	day_order = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

	df_weekday_stats = df_processed.groupby("day_of_week")[metrics_to_be_plot].median().reindex(day_order)

	fig_weekly, axes_weekly = plt.subplots(2, 3, figsize=(15, 8), constrained_layout=True)
	axes_weekly = axes_weekly.flatten()

	for i, metrics in enumerate(metrics_to_be_plot):
		sns.barplot(ax=axes_weekly[i], x=df_weekday_stats.index, y=df_weekday_stats[metrics], order=day_order, palette="viridis", hue=df_weekday_stats.index, legend=False)
		title = f"Median {metrics.replace('_', ' ').title()} by Day of Week"
		ylabel = f"Median {metrics.replace('_', ' ').title()}"

		axes_weekly[i].set_title(title)
		axes_weekly[i].set_xlabel("Day of week")
		axes_weekly[i].set_ylabel(ylabel)
		axes_weekly[i].tick_params(axis = "x", rotation=45)
		# plt.show()

	

	df_monthly_stats = df_processed.groupby("month")[metrics_to_be_plot].median()
	
	month_names = [calendar.month_abbr[i] for i in range(1, 13)]
	df_monthly_stats.index = df_monthly_stats.index.map(lambda x: calendar.month_abbr[x])
	df_monthly_stats = df_monthly_stats.reindex(month_names)

	fig_monthly, axes_monthly = plt.subplots(2, 3, figsize=(15, 8), constrained_layout=True)
	axes_monthly = axes_monthly.flatten()

	for i, metrics in enumerate(metrics_to_be_plot):
		sns.barplot(ax=axes_monthly[i], x=df_monthly_stats.index, y=df_monthly_stats[metrics], palette="viridis")

		title = f"Median {metrics.replace('_', ' ').title()}"
		ylabel = f"Median {metrics.replace('_', ' ').title()}"

		axes_monthly[i].set_title(title)
		axes_monthly[i].set_xlabel("Month")
		axes_monthly[i].set_ylabel(ylabel)
		axes_weekly[i].tick_params(axis = "x", rotation=45)
		# plt.show()
	
	plt.show()
	
	
except FileNotFoundError:
	print(f"Error: file not found {DB_PATH}")
except sqlite3.Error as e:
	print(f"Error at database: {e}")
finally:
	if "conn" in locals() and conn:
		conn.close()
		print("Database connection is closed")
