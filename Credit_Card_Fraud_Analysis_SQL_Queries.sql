/*
PROJECT: Credit Card Fraud Analysis and Rule Simulation
DATABASE: CreditCardFraudAnalysis
PLATFORM: Microsoft SQL Server (T-SQL)

DESCRIPTION
This script contains SQL analyses for overall fraud volume, category/time/state
patterns, transaction amount bands, time gaps between fraudulent transactions,
and simple amount-threshold simulations.

REQUIREMENTS
- Run in Microsoft SQL Server after importing the dataset into dbo.txns.
- Expected columns include: is_fraud, amt, category, trans_date_trans_time,
  state, and cc_num.
- Review results and validate threshold definitions before drawing business
  conclusions. Amount-based rules are illustrative simulations, not a production
  fraud-detection model.

NOTE
The time-gap query displays only the last four digits of cc_num rather than the
full card number in its output.
*/

USE CreditCardFraudAnalysis;
GO



/* ============================================================
   01. Overall Fraud Summary
   ============================================================ */

SELECT
    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,

    SUM(CASE
        WHEN is_fraud = 0 THEN 1
        ELSE 0
    END) AS genuine_transactions,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 3)
    ) AS fraud_rate_pct,

    SUM(CASE
        WHEN is_fraud = 1 THEN amt
        ELSE 0
    END) AS fraud_transaction_amount

FROM dbo.txns;
GO


/* ============================================================
   02. Fraud by Category
   ============================================================ */

SELECT
    category,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN amt
        ELSE 0
    END) AS fraud_associated_amount,

    AVG(CASE
        WHEN is_fraud = 1 THEN amt
    END) AS avg_fraud_transaction_amount

FROM dbo.txns
GROUP BY category

HAVING SUM(CASE
    WHEN is_fraud = 1 THEN 1
    ELSE 0
END) > 0

ORDER BY fraud_transactions DESC;
GO


/* ============================================================
   03. Fraud by Transaction Amount Band
   ============================================================ */

SELECT
    amount_band,
    COUNT(*) AS fraud_transactions,
    SUM(amt) AS fraud_associated_amount,
    AVG(amt) AS avg_fraud_transaction_amount
FROM (
    SELECT
        amt,
        CASE
            WHEN amt < 100 THEN 'Under 100'
            WHEN amt < 500 THEN '100-499.99'
            WHEN amt < 1000 THEN '500-999.99'
            ELSE '1000+'
        END AS amount_band
    FROM dbo.txns
    WHERE is_fraud = 1
) AS t
GROUP BY amount_band
ORDER BY CASE amount_band
    WHEN 'Under 100' THEN 1
    WHEN '100-499.99' THEN 2
    WHEN '500-999.99' THEN 3
    ELSE 4
END;
GO


/* ============================================================
   04. Fraud by Hour
   ============================================================ */

SELECT
    DATEPART(HOUR, trans_date_trans_time) AS transaction_hour,
    COUNT(*) AS fraud_transactions,
    SUM(amt) AS fraud_associated_amount,
    AVG(amt) AS avg_fraud_transaction_amount
FROM dbo.txns
WHERE is_fraud = 1
GROUP BY DATEPART(HOUR, trans_date_trans_time)
ORDER BY transaction_hour;
GO


/* ============================================================
   05. Fraud by State
   ============================================================ */

SELECT
    state,
    COUNT(*) AS fraud_transactions,
    SUM(amt) AS fraud_associated_amount,
    AVG(amt) AS avg_fraud_transaction_amount
FROM dbo.txns
WHERE is_fraud = 1
GROUP BY state
ORDER BY fraud_transactions DESC;
GO


/* ============================================================
   06. Time Gaps Between Fraud Transactions
   ============================================================ */

WITH FraudTransactions AS (
    SELECT
        RIGHT(CONVERT(VARCHAR(20), cc_num), 4) AS card_last4,
        trans_date_trans_time,
        amt,
        LAG(trans_date_trans_time) OVER (
            PARTITION BY cc_num
            ORDER BY trans_date_trans_time
        ) AS previous_fraud_time
    FROM dbo.txns
    WHERE is_fraud = 1
)
SELECT
    card_last4,
    previous_fraud_time,
    trans_date_trans_time AS current_fraud_time,
    DATEDIFF(
        MINUTE,
        previous_fraud_time,
        trans_date_trans_time
    ) AS minutes_between_fraud
FROM FraudTransactions
WHERE previous_fraud_time IS NOT NULL
ORDER BY card_last4, trans_date_trans_time
;
GO


/* ============================================================
   07. Fraud Rate by Category
   ============================================================ */

SELECT
    category,

    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS fraud_rate_pct

FROM dbo.txns
GROUP BY category
ORDER BY fraud_rate_pct DESC;
GO


/* ============================================================
   08. Fraud Rate by Transaction Amount Band
   ============================================================ */

SELECT
    amount_band,
    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS fraud_rate_pct

FROM (
    SELECT
        is_fraud,
        CASE
            WHEN amt < 100 THEN 'Under 100'
            WHEN amt < 500 THEN '100-499.99'
            WHEN amt < 1000 THEN '500-999.99'
            ELSE '1000+'
        END AS amount_band
    FROM dbo.txns
) AS t

GROUP BY amount_band

ORDER BY CASE amount_band
    WHEN 'Under 100' THEN 1
    WHEN '100-499.99' THEN 2
    WHEN '500-999.99' THEN 3
    ELSE 4
END;
GO


/* ============================================================
   09. Fraud Rate by Hour
   ============================================================ */

SELECT
    DATEPART(HOUR, trans_date_trans_time) AS transaction_hour,

    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS fraud_rate_pct

FROM dbo.txns
GROUP BY DATEPART(HOUR, trans_date_trans_time)
ORDER BY fraud_rate_pct DESC;
GO


/* ============================================================
   10. Fraud Rate by State
   ============================================================ */

SELECT
    state,

    COUNT(*) AS total_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS fraud_rate_pct

FROM dbo.txns
GROUP BY state
ORDER BY fraud_rate_pct DESC;
GO


/* ============================================================
   11. Fraud vs Genuine Transaction Amounts
   ============================================================ */

SELECT
    CASE
        WHEN is_fraud = 1 THEN 'Fraud'
        ELSE 'Genuine'
    END AS transaction_type,

    COUNT(*) AS total_transactions,

    SUM(amt) AS total_transaction_amount,

    CAST(AVG(amt) AS DECIMAL(10, 2))
        AS avg_transaction_amount,

    CAST(MIN(amt) AS DECIMAL(10, 2))
        AS min_transaction_amount,

    CAST(MAX(amt) AS DECIMAL(10, 2))
        AS max_transaction_amount

FROM dbo.txns
GROUP BY is_fraud
ORDER BY is_fraud;
GO


/* ============================================================
   12. Test Fraud Detection Rule: Amount >= 500
   ============================================================ */

SELECT
    COUNT(*) AS flagged_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions_caught,

    SUM(CASE
        WHEN is_fraud = 0 THEN 1
        ELSE 0
    END) AS genuine_transactions_flagged,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS precision_pct,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) /
        (SELECT COUNT(*)
         FROM dbo.txns
         WHERE is_fraud = 1)
        AS DECIMAL(10, 2)
    ) AS recall_pct

FROM dbo.txns
WHERE amt >= 500;
GO


/* ============================================================
   13. Compare Amount Thresholds
   ============================================================ */

SELECT
    threshold_amount,

    COUNT(*) AS flagged_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions_caught,

    SUM(CASE
        WHEN is_fraud = 0 THEN 1
        ELSE 0
    END) AS genuine_transactions_flagged,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS precision_pct,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) /
        (SELECT COUNT(*)
         FROM dbo.txns
         WHERE is_fraud = 1)
        AS DECIMAL(10, 2)
    ) AS recall_pct

FROM (
    SELECT 100 AS threshold_amount, is_fraud, amt
    FROM dbo.txns
    WHERE amt >= 100

    UNION ALL

    SELECT 250 AS threshold_amount, is_fraud, amt
    FROM dbo.txns
    WHERE amt >= 250

    UNION ALL

    SELECT 500 AS threshold_amount, is_fraud, amt
    FROM dbo.txns
    WHERE amt >= 500

    UNION ALL

    SELECT 1000 AS threshold_amount, is_fraud, amt
    FROM dbo.txns
    WHERE amt >= 1000
) AS thresholds

GROUP BY threshold_amount
ORDER BY threshold_amount;
GO


/* ============================================================
   14. Final Evaluation of Amount >= 250 Threshold
   ============================================================ */

SELECT
    COUNT(*) AS flagged_transactions,

    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions_caught,

    SUM(CASE
        WHEN is_fraud = 0 THEN 1
        ELSE 0
    END) AS genuine_transactions_flagged,

    (SELECT COUNT(*)
     FROM dbo.txns
     WHERE is_fraud = 1)
    -
    SUM(CASE
        WHEN is_fraud = 1 THEN 1
        ELSE 0
    END) AS fraud_transactions_missed,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) / COUNT(*) AS DECIMAL(10, 2)
    ) AS precision_pct,

    CAST(
        100.0 * SUM(CASE
            WHEN is_fraud = 1 THEN 1
            ELSE 0
        END) /
        (SELECT COUNT(*)
         FROM dbo.txns
         WHERE is_fraud = 1)
        AS DECIMAL(10, 2)
    ) AS recall_pct

FROM dbo.txns
WHERE amt >= 250;
GO
