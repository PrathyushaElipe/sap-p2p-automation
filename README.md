# SAP P2P Automation and Anomaly Detection

> SAP ABAP | SAP MM | ALV Reports | Open SQL | S/4HANA

## What This Project Does

This project automates the Procure-to-Pay (P2P) matching process in SAP.
It reads Purchase Order data and Invoice data from SAP MM standard tables,
compares them line by line, and flags any mismatches as anomalies.

The output is a color-coded ALV grid report:
- 🟢 Green rows = PO and invoice matched correctly
- 🔴 Red rows  = anomaly detected (price variance, over-delivery, zero amount)
- 🟡 Yellow rows = PO has no invoice posted yet

## SAP Tables Used

| Table | Description |
|-------|-------------|
| EKKO  | Purchase Order Header |
| EKPO  | Purchase Order Items  |
| RSEG  | Invoice Line Items    |
| RBKP  | Invoice Header        |

## Custom Objects Created in SE11

|     Object     |                             Name                                               |            Purpose                  |
|----------------|--------------------------------------------------------------------------------|----------------------------------   |
| Package        |                          ZPKG_08                                               |     Contains all project objects    |
| Database Table |                 ZP2P_RESULTS                                                   |  Stores matching and anomaly output |
| Domains        | ZD_P2P_STATUS, ZD_P2P_REASON, ZD_P2P_VARIANCE, ZD_P2P_FLAG, ZD_P2P_ROWCOLOR    |      Data type definitions          |
| Data Elements  | ZDE_P2P_STATUS, ZDE_P2P_REASON, ZDE_P2P_VARIANCE, ZDE_P2P_FLAG,ZDE_P2P_ROWCOLOR|       Field labels and types        |
| Message Class  |                   ZMM_P2P                                                      |          Program messages           |
| Transaction    |                 ZP2P_MAIN                                                      |        Runs ZP2P_REPORT directly    |

## Three Program Architecture

|    Program  | Purpose |
|-------------|---------|
| ZP2P_FETCH  | Reads POs and invoices from EKKO, EKPO, RSEG and saves to ZP2P_RESULTS |
| ZP2P_MATCH  | Reads ZP2P_RESULTS, calculates variance %, applies anomaly rules, updates each row |
| ZP2P_REPORT | Reads final data from ZP2P_RESULTS and displays color-coded ALV grid |

## Anomaly Detection Rules

1. **Price Variance > 5%** — Invoice amount differs from PO expected amount by more than 5%
2. **Over Delivery** — Invoice quantity is greater than PO quantity
3. **Zero Amount** — Invoice was posted with zero amount
4. **Not Invoiced** — PO item has no invoice posted against it at all

## How to Run
Step 1 — SE38 → ZP2P_FETCH → F8 → enter PO range → F8
Step 2 — SE38 → ZP2P_MATCH → F8
Step 3 — SE38 → ZP2P_REPORT → F8  (or transaction ZP2P_MAIN)

## Screenshots

See the /screenshots folder for output from the live SAP system.

## Author

**Prathyusha Elipe**
SAP ABAP Developer | Certified SAP ABAP on HANA | SAP BTP
- LinkedIn: [linkedin.com/in/prathyusha-elipe](https://linkedin.com/in/prathyusha-elipe)
- Email: elipeprathyusha@gmail.com
