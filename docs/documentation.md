# Projektdokumentation – E-Commerce Performance Dashboard

## Dashboard

Unter: LINK

Oder manuell im Projekt Verzeichniss starten
```bash
pip install -r requirements.txt
streamlit run scripts/05_visualization/dashboard.py
```
---
---

## Executive Summary

Dieses Projekt analysiert einen realen E-Commerce-Marktplatz auf Basis von Transaktionsdaten des brasilianischen Unternehmens Olist.

Die Analyse zeigt drei zentrale Erkenntnisse:

- **Umsatz ist stark konzentriert**: Ein kleiner Anteil von Kunden und Sellern generiert den Großteil des Umsatzes  
- **Delivery Performance ist der wichtigste Treiber der Customer Experience**  
- **Kundenstruktur ist unausgewogen**: Viele Low-Value-Kunden stehen wenigen umsatzstarken Kunden gegenüber  

**Zentrale Implikation:**  
Operative Verbesserungen in der Logistik sowie gezielte Strategien zur Kundenbindung haben den größten Einfluss auf Umsatz und Kundenzufriedenheit.

## Dashboard Overview

![Dashboard Overview](../assets/screenshots/dashboard_overview.png)
---

## Inhaltsverzeichnis

1. Business Context  
2. Zielsetzung und Projektfokus  
3. Projektcharakter  
4. Datenbasis  
5. Datenaufbereitung und Reporting-Architektur  
6. KPI-Logik und Modellierungsansatz  
7. Dashboard-Struktur  
8. Analytische Möglichkeiten  
9. Zentrale Analyseergebnisse (detailliert)  
10. Business Implications  
11. Operativer Mehrwert  
12. Validierung und Datenqualität  
13. Limitationen  
14. Erweiterungen  
15. Fazit  

---

## 1. Business Context

Dieses Projekt bildet einen praxisnahen BI-Workflow für einen realen E-Commerce-Marktplatz ab.

Die Daten stammen von **Olist**, einem brasilianischen Unternehmen, das eine Plattform betreibt, über die Händler ihre Produkte über verschiedene Online-Kanäle verkaufen. Es handelt sich um reale, anonymisierte Transaktionsdaten.

Der Marktplatz integriert:

- Kunden (Nachfrage)  
- Seller (Angebot)  
- Logistik (Delivery)  
- Zahlungsabwicklung  

Typische Herausforderungen:

- Umsatzkonzentration auf wenige Akteure  
- heterogene Performance zwischen Sellern und Kategorien  
- operative Probleme wirken direkt auf Kundenzufriedenheit  
- fehlende integrierte Sicht auf Umsatz, Delivery und Reviews  

**Zentrale Herausforderung:**  
Ohne strukturierte Datenbasis lassen sich diese Zusammenhänge nicht konsistent analysieren.

---

## 2. Zielsetzung und Projektfokus

Ziel ist der Aufbau einer Analyse- und Reportingbasis, die:

- operative und kommerzielle Daten integriert  
- konsistente KPIs bereitstellt  
- Ursache-Wirkungs-Zusammenhänge sichtbar macht  
- eine fundierte Entscheidungsbasis ermöglicht  

Leitfrage:

> Wie lassen sich reale Marktplatzdaten so modellieren, dass daraus belastbare Analysen und Entscheidungen entstehen?

---

## 3. Projektcharakter

Dieses Projekt bildet eine typische BI-/Reporting-Lösung ab:

- SQL-basierte Datenaufbereitung  
- klare Trennung von Datenbasis und Analyse  
- konsistente KPI-Definitionen  
- Fokus auf interpretierbare Ergebnisse  

Der Schwerpunkt liegt auf:

- strukturierter Analyse  
- nachvollziehbarer KPI-Logik  
- business-orientierter Interpretation  

---

## 4. Datenbasis

Der Datensatz umfasst:

- mehrere hunderttausend Bestellungen  
- Zahlungsdaten  
- Lieferzeiten  
- Kundenbewertungen  
- Produkt- und Kategorieninformationen  

Eigenschaften:

- real  
- relational  
- operativ geprägt  

---

## 5. Datenaufbereitung und Reporting-Architektur

### Pipeline

```text
Raw → Validation → Analysis → Export → Dashboard
```

### Prinzipien

- Trennung von Rohdaten und Analyse  
- wiederverwendbare SQL-Logik  
- klare analytische Ebenen  

---

## 6. KPI-Logik und Modellierungsansatz

Zentrale Grundlage:

> Order-Fact-Tabelle als konsistente Datenbasis

### KPIs

- Revenue  
- Orders  
- Average Order Value  
- Delivery Time  
- Late Delivery Rate  
- Review Score  

### Ziel

- einfache, robuste und interpretierbare Kennzahlen  
- konsistente Berechnung über alle Analysen hinweg  

---

## 7. Dashboard-Struktur

- Executive Overview  
- Revenue Distribution  
- Seller Concentration  
- Delivery Performance  
- Review vs Delivery  
- Root Cause Analysis  
- Customer Segmentation  
- Product & Category  
- Payment Analysis  

---

## 8. Analytische Möglichkeiten

- Pareto-Analysen  
- Segmentanalysen  
- Delivery-Analysen  
- Zusammenhangsanalysen (Delivery vs Reviews)  
- Kategorie- und Produktanalysen  

---

## 9. Zentrale Analyseergebnisse (detailliert)

### Umsatzstruktur

- starke Konzentration auf wenige Kunden  
- Top-Decile dominiert Umsatz  

→ Abhängigkeit von High-Value-Kunden  

![Revenue Distribution](../assets/screenshots/revenue_distribution.png)

---

### Seller-Struktur

- wenige Seller treiben Großteil des Umsatzes  
- Long-Tail-Struktur  

→ Risiko durch Konzentration

![Revenue Distribution](../assets/screenshots/seller_concentration.PNG)

---

### Delivery Performance

- stabile Durchschnittswerte  
- hohe Varianz  
- relevante Verzögerungen  

→ operative Ineffizienzen vorhanden  

![Delivery Performance](../assets/screenshots/delivery_performance.png)

---

### Delivery vs Reviews

- klare negative Korrelation  
- verspätete Lieferung → deutlich schlechtere Bewertungen  

→ zentraler Zusammenhang im System  

![Review vs Delivery](../assets/screenshots/review_delivery.png)

---

### Root Cause

- Low Reviews korrelieren stark mit Late Deliveries  
- kaum Zusammenhang mit Order Value  

→ Haupttreiber = Delivery  

![Root Cause Analysis](../assets/screenshots/root_cause.png)

---

### Kategorien

- wenige Kategorien dominieren Umsatz  
- Trade-off zwischen Volumen und Qualität  

---

### Customer Segmentation

- wenige Kunden generieren Großteil des Umsatzes  
- geringe Loyalität  

→ Potenzial für Retention-Strategien  

![Customer Segmentation](../assets/screenshots/customer_segments.png)

---

## 10. Business Implications

Die Analyse zeigt drei zentrale Handlungsfelder:

### 1. Delivery Performance als kritischer Hebel
- Reduktion von Verzögerungen verbessert direkt die Customer Experience  
- operative Optimierung hat unmittelbaren Einfluss auf Reviews  

### 2. Hohe Umsatzkonzentration
- Fokus auf Retention von High-Value-Kunden  
- Diversifikation reduziert Risiko  

### 3. Schwache Kundenbindung
- Aufbau von Loyalitätsstrategien  
- Förderung wiederkehrender Käufe  

---

## 11. Operativer Mehrwert

Das Dashboard ermöglicht:

- Identifikation von Umsatztreibern  
- Analyse operativer Schwächen  
- Priorisierung von Maßnahmen  

Typische Anwendung:

- Analyse von Delivery-Problemen  
- Bewertung von Kundensegmenten  
- Ableitung von Optimierungsmaßnahmen  

---

## 12. Validierung und Datenqualität

- Duplikatkontrollen  
- Join-Validierungen  
- Plausibilitätsprüfungen  
- KPI-Konsistenz  

---

## 13. Limitationen

- keine kausalen Modelle  
- keine externen Einflussfaktoren  
- statische Datenbasis  

---

## 14. Erweiterungen

- Cohort-Analyse  
- Retention-Modelle  
- Forecasting  
- detailliertere Segmentierung  

---

## 15. Fazit

Das Projekt zeigt den Aufbau einer vollständigen BI-Analyse:

- strukturierte Datenbasis  
- konsistente KPI-Logik  
- integrierte Analyse von Umsatz, Delivery und Customer Experience  

**Zentrale Erkenntnis:**

> Delivery Performance ist der wichtigste Hebel für Kundenzufriedenheit, während Umsatz stark konzentriert ist.

Das Projekt demonstriert, wie reale Daten in **strukturierte, entscheidungsrelevante Analysen** überführt werden können.