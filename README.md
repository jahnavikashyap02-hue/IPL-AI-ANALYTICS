# IPL Performance & Strategy Analytics

An end-to-end IPL analytics project combining Python, SQL, Power BI, XGBoost and Generative AI to analyze team performance, player statistics, match strategy and historical IPL trends.

## Project Objective

The objective of this project is to transform IPL match and ball-by-ball data into actionable analytical insights through data cleaning, exploratory analysis, SQL analytics, interactive Power BI dashboards, machine learning and GenAI.

## Key Components

- Python/Pandas for data cleaning and feature engineering
- Exploratory Data Analysis for identifying performance trends
- SQL for business and strategic analysis
- Power BI for interactive dashboarding
- XGBoost for historical match-outcome classification
- GenAI for natural-language analytics and insight generation

## Business Questions

The project investigates questions such as:

1. Which teams have the strongest historical win performance?
2. Which players have the highest run and wicket production?
3. Which players combine high scoring with strong strike rates?
4. How do teams perform during powerplay and death overs?
5. How do batting-first and chasing outcomes compare historically?
6. How do scoring patterns vary across venues?
7. Which variables contribute to the ML model's predictions?
8. How can GenAI make IPL analytics easier to explore using natural language?

## Outcome

The final solution provides an end-to-end analytics workflow from raw IPL data to business insights, interactive dashboards, machine learning analysis and a GenAI-powered analytics interface.

├── Matplotlib
├── Seaborn
└── Scikit-learn

Machine Learning
└── XGBoost

Database
└── MySQL

Visualization
└── Power BI

Generative AI
└── OpenAI API

Development
└── VS Code

Version Control
└── Git & GitHub

## Project Pipeline

Raw IPL Data
      ↓
Data Cleaning
      ↓
Feature Engineering
      ↓
Exploratory Data Analysis
      ↓
SQL Business Analysis
      ↓
Power BI Dashboard
      ↓
XGBoost Model
      ↓
GenAI Analytics Copilot
      ↓
Business Insights

## Power BI Dashboard

### Executive Overview

![Executive Overview](images/executive_overview.png)

### Player Analytics

![Player Analytics](images/player_analytics.png)

### Team & Strategy

![Team & Strategy](images/team_&_strategy.png)

### AI & ML Insights

![AI & ML Insights](images/AI_&_ML_Insight.png)

### GenAI Executive Insight

![Gen AI Executive Insight](image/GENAI_Executive_Insight)

## How to Run

### 1. Clone the repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

### 2. Create a virtual environment

```bash
python -m venv .venv
```

### 3. Activate the environment

Windows:

```bash
.venv\Scripts\activate
```

### 4. Install dependencies

```bash
pip install -r requirements.txt
```

### 5. Explore the notebooks

Open the notebooks inside the `notebooks/` directory using VS Code or Jupyter.

### 6. Open the Power BI dashboard

Open:

```text
powerbi/IPL_Analytics_Dashboard.pbix
```

### 7. Run the GenAI analytics component

Configure the required API key through an environment variable and run:

```bash
python ai/genai_copilot.py
```

Do not commit API keys or `.env` files to the repository.