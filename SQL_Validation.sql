-- PROJECT: Cryptocurrency Financial Performance Analysis

-- Database setup
CREATE DATABASE crypto_analysis;
USE crypto_analysis;

-- Table Creation
CREATE TABLE crypto_prices (
    name VARCHAR(50),
    symbol VARCHAR(10),
    date DATETIME,
    high DOUBLE,
    low DOUBLE,
    open DOUBLE,
    close DOUBLE,
    volume DOUBLE,
    marketcap DOUBLE,
    coin VARCHAR(20),
    daily_return DOUBLE,
    cumulative_return DOUBLE,
    running_peak DOUBLE,
    drawdown DOUBLE
);

-- Data Validation
-- 1. Total number of records
SELECT COUNT(*) AS total_rows FROM crypto_prices;
-- 2. Table Preview
SELECT * FROM crypto_prices LIMIT 20;

-- Daily Return Validation 
-- 1. Recalculate daily returns using SQL window functions
SELECT coin, date, close,
LAG(close) OVER (PARTITION BY coin ORDER BY date) AS prev_close,
(close / LAG(close) OVER (PARTITION BY coin ORDER BY date) - 1) AS daily_return_sql
FROM crypto_prices;

-- Risk Analysis
-- 1. Volatility (risk)
SELECT coin, STDDEV(daily_return) AS volatility FROM crypto_prices
GROUP BY coin;

-- Performance Analysis
-- 1. Total cumulative return per asset
SELECT coin, MAX(cumulative_return) AS total_return FROM crypto_prices
GROUP BY coin;

-- Drawdown Analysis
-- 1. Maximum drawdown (worst loss from peak)
SELECT coin, MIN(drawdown) AS max_drawdown FROM crypto_prices
GROUP BY coin;

-- 2. Number of days spent in drawdown
SELECT coin, COUNT(*) AS days_in_drawdown FROM crypto_prices
WHERE drawdown < 0 GROUP BY coin;

-- Risk-Adjusted Performance
-- 1. Simple risk-adjusted return metric
SELECT coin,AVG(daily_return) / STDDEV(daily_return) AS risk_adjusted_return
FROM crypto_prices GROUP BY coin ORDER BY risk_adjusted_return DESC;

-- Rolling Risk Metrics
SELECT coin, date,
STDDEV(daily_return) OVER (
        PARTITION BY coin
        ORDER BY date
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS rolling_30d_volatility
FROM crypto_prices;