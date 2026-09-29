import pandas as pd
import matplotlib.pyplot as plt

matches = pd.read_csv("data/raw/matches.csv")
deliveries = pd.read_csv("data/raw/deliveries.csv")

print("Matches loaded:", matches.shape)
print("Deliveries loaded:", deliveries.shape)
print(matches.shape)
print(deliveries.shape)
print(matches.head())
print(deliveries.head())

print("MATCH COLUMNS")
print(matches.columns.tolist())

print("\nDELIVERY COLUMNS")
print(deliveries.columns.tolist())

print(matches.info())

print(deliveries.info())
print(matches.isnull().sum())
print(deliveries.isnull().sum())

print("Duplicate matches:", matches.duplicated().sum())
print("Duplicate deliveries:", deliveries.duplicated().sum())

print(sorted(matches["season"].unique()))
print("Number of seasons:",
      matches["season"].nunique())
teams = pd.unique(
    matches[["team1", "team2"]].values.ravel()
)

print("Number of teams:", len(teams))
print(teams)
batters = deliveries["batter"].nunique()
bowlers = deliveries["bowler"].nunique()

print("Unique batters:", batters)
print("Unique bowlers:", bowlers)
players = set(deliveries["batter"].dropna()) | set(
    deliveries["bowler"].dropna()
)

print("Unique players:", len(players))
top_run_scorers = (
    deliveries
    .groupby("batter")["batsman_runs"]
    .sum()
    .sort_values(ascending=False)
    .head(10)
)

print(top_run_scorers)
top_six_hitters = (
    deliveries[deliveries["batsman_runs"] == 6]
    .groupby("batter")
    .size()
    .sort_values(ascending=False)
    .head(10)
)

print(top_six_hitters)
wickets = deliveries[
    deliveries["is_wicket"] == 1
]
top_wicket_takers = (
    wickets
    .groupby("bowler")
    .size()
    .sort_values(ascending=False)
    .head(10)
)

print(top_wicket_takers)
team_wins = (
    matches["winner"]
    .value_counts()
)

print(team_wins.head(10))

toss_match_winner = (
    matches["toss_winner"] ==
    matches["winner"]
)

print(
    "Toss winner also won:",
    toss_match_winner.mean() * 100,
    "%"
)
total_runs = deliveries["total_runs"].sum()

print("Total IPL runs:", total_runs)
total_sixes = (
    deliveries["batsman_runs"] == 6
).sum()

print("Total sixes:", total_sixes)
total_fours = (
    deliveries["batsman_runs"] == 4
).sum()

print("Total fours:", total_fours)

team_wins.head(10).plot(
    kind="bar",
    figsize=(10, 6)
)

plt.title("Top IPL Teams by Number of Wins")
plt.xlabel("Team")
plt.ylabel("Wins")
plt.xticks(rotation=45)

plt.tight_layout()
plt.savefig("data/processed/plot.png")
plt.close()

matches.to_csv(
    "data/processed/matches_initial.csv",
    index=False
)

deliveries.to_csv(
    "data/processed/deliveries_initial.csv",
    index=False
)
print(matches.columns.tolist())
print(deliveries.columns.tolist())