# Streamlit-Dashboard für das Olist E-Commerce Analyseprojekt
# Das Skript lädt die zuvor erzeugten Analyse-Exporte und bereitet sie
# für eine interaktive Visualisierung in mehreren Analysebereichen auf.
#
# Enthalten sind unter anderem Auswertungen zu Umsatzverteilung,
# Seller-Konzentration, Delivery Performance, Reviews, Kundensegmenten,
# Produktkategorien und Zahlungsarten.
#
# Hinweis:
# Das Skript wurde KI-gestützt erstellt, anschließend überprüft und an das
# Projekt angepasst. Der Fokus liegt auf der Ausführung und Nutzung im
# Dashboard, nicht auf einer ausführlichen manuellen Lesbarkeit des Codes.
#
# Nutzung:
# Dashboard über den Projektlink öffnen: 
#
#
# oder lokal im Projektverzeichnis starten:
#
# pip install streamlit pandas matplotlib pillow
# streamlit run scripts/05_visualization/dashboard.py

import streamlit as st
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
from pathlib import Path
from PIL import Image

# --------------------------------------------------
# Page setup
# --------------------------------------------------
st.set_page_config(
    page_title="Olist - E-Commerce Analysis Dashboard",
    page_icon=None,
    layout="wide"
)

# --------------------------------------------------
# Paths
# --------------------------------------------------
BASE_DIR = Path(__file__).resolve().parents[2]
DATA_PATH = BASE_DIR / "data" / "analysis_exports"
LOGO_PATH = BASE_DIR / "assets" / "olist_logo.png"

# --------------------------------------------------
# Theme / colors
# --------------------------------------------------
PRIMARY_GREEN = "#2e7d32"
MID_GREEN = "#64a86b"
DARK_GREEN = "#1f4d2e"
TEXT_GREEN = "#355e3b"
GRID_COLOR = "#c7d9c9"
CARD_BG = "#f4f7f4"

# --------------------------------------------------
# Styling
# --------------------------------------------------
CUSTOM_CSS = """
<style>
    .main {
        background-color: #06110b;
    }

    .block-container {
        padding-top: 1.5rem;
        padding-bottom: 2rem;
        max-width: 1450px;
    }

    h1, h2, h3 {
        color: #f3f6f4 !important;
    }

    p, div, span, label {
        color: #dbe7df;
    }

    .stMetric {
        background-color: #101914;
        border: 1px solid #1f3a2b;
        border-radius: 14px;
        padding: 14px 18px;
        box-shadow: 0 2px 10px rgba(0, 0, 0, 0.18);
    }

    .stMetric label {
        color: #a9c6b0 !important;
        font-weight: 600;
    }

    .stMetric [data-testid="stMetricValue"] {
        color: #f3f6f4;
    }

    section[data-testid="stSidebar"] {
        background: linear-gradient(180deg, #101b15 0%, #0c1410 100%);
        border-right: 1px solid #1f3a2b;
    }

    section[data-testid="stSidebar"] * {
        color: #dbe7df !important;
    }

    div[data-testid="stDataFrame"] {
        border: 1px solid #2a3f31;
        border-radius: 10px;
        overflow: hidden;
    }

    .insight-box {
        background-color: #0f1a14;
        border: 1px solid #1f3a2b;
        border-left: 4px solid #2e7d32;
        border-radius: 10px;
        padding: 0.8rem 1rem;
        margin: 0.5rem 0 1rem 0;
        color: #dbe7df;
    }

    .section-note {
        color: #c6d9cb;
        font-size: 0.98rem;
        margin-bottom: 1rem;
    }
</style>
"""
st.markdown(CUSTOM_CSS, unsafe_allow_html=True)

# --------------------------------------------------
# Matplotlib defaults
# --------------------------------------------------
plt.rcParams.update({
    "figure.facecolor": CARD_BG,
    "axes.facecolor": CARD_BG,
    "axes.edgecolor": "#b8cbb8",
    "axes.labelcolor": DARK_GREEN,
    "axes.titlecolor": DARK_GREEN,
    "xtick.color": TEXT_GREEN,
    "ytick.color": TEXT_GREEN,
    "grid.color": GRID_COLOR,
    "grid.linestyle": "--",
    "grid.linewidth": 0.7,
    "font.size": 10,
    "axes.titlesize": 13,
    "axes.labelsize": 10
})

# --------------------------------------------------
# File config
# --------------------------------------------------
FILES = {
    "customer_pareto": "customer_revenue_pareto.csv",
    "customer_deciles": "customer_revenue_deciles.csv",
    "seller_pareto": "seller_revenue_pareto.csv",
    "seller_deciles": "seller_revenue_deciles.csv",
    "delivery_monthly": "delivery_performance_monthly.csv",
    "delivery_status": "delivery_performance_by_status.csv",
    "delivery_buckets": "delivery_time_buckets.csv",
    "review_score": "review_vs_delivery_score.csv",
    "review_bucket": "review_vs_delivery_bucket.csv",
    "review_late": "review_late_vs_ontime.csv",
    "review_revenue_segment": "review_delivery_by_revenue_segment.csv",
    "low_review_drivers": "low_review_drivers.csv",
    "review_delivery_combined": "review_delivery_combined.csv",
    "category_perf": "category_performance.csv",
    "product_perf": "product_performance.csv",
    "category_review": "category_review_performance.csv",
    "payment_mix": "payment_type_mix.csv",
    "payment_installments": "payment_installments.csv",
    "payment_review": "payment_type_review.csv",
    "payment_delivery": "payment_type_delivery.csv",
    "customer_segments": "customer_segments.csv",
    "customer_segment_summary": "customer_segment_summary.csv",
    "customer_segment_delivery_review": "customer_segment_delivery_review.csv",
    "customer_segment_monthly": "customer_segment_monthly.csv",
}

REQUIRED_KEYS = [
    "customer_pareto",
    "customer_deciles",
    "seller_pareto",
    "seller_deciles",
    "delivery_monthly",
    "delivery_status",
    "delivery_buckets",
    "review_score",
    "review_bucket",
    "review_late",
    "review_revenue_segment",
    "low_review_drivers",
    "review_delivery_combined",
    "category_perf",
    "product_perf",
    "category_review",
    "payment_mix",
    "payment_installments",
    "payment_review",
    "payment_delivery",
    "customer_segment_summary",
    "customer_segment_delivery_review",
    "customer_segment_monthly",
]

PAGE_OPTIONS = [
    "Executive Overview",
    "Revenue Distribution",
    "Seller Concentration",
    "Delivery Performance",
    "Review vs Delivery",
    "Root Cause Analysis",
    "Customer Segmentation",
    "Product & Category",
    "Payment Analysis"
]

# --------------------------------------------------
# Label mappings
# --------------------------------------------------
CATEGORY_LABELS = {
    "toys": "Toys",
    "health_beauty": "Health & Beauty",
    "construction_tools_construction": "Construction Tools: Construction",
    "fixed_telephony": "Fixed Telephony",
    "security_and_services": "Security & Services",
    "costruction_tools_garden": "Construction Tools: Garden",
    "computers_accessories": "Computers & Accessories",
    "bed_bath_table": "Bed, Bath & Table",
    "party_supplies": "Party Supplies",
    "kitchen_dining_laundry_garden_furniture": "Kitchen, Dining, Laundry & Garden Furniture",
    "housewares": "Housewares",
    "portateis_cozinha_e_preparadores_de_alimentos": "Portable Kitchen & Food Preparers",
    "art": "Art",
    "home_appliances_2": "Home Appliances 2",
    "baby": "Baby",
    "food": "Food",
    "fashion_childrens_clothes": "Fashion: Children's Clothes",
    "books_technical": "Books: Technical",
    "home_confort": "Home Comfort",
    "market_place": "Marketplace",
    "stationery": "Stationery",
    "costruction_tools_tools": "Construction Tools: Tools",
    "furniture_bedroom": "Bedroom Furniture",
    "cool_stuff": "Cool Stuff",
    "perfumery": "Perfumery",
    "signaling_and_security": "Signaling & Security",
    "books_imported": "Books: Imported",
    "air_conditioning": "Air Conditioning",
    "office_furniture": "Office Furniture",
    "musical_instruments": "Musical Instruments",
    "cine_photo": "Cinema & Photo",
    "sports_leisure": "Sports & Leisure",
    "unknown": "Unknown",
    "telephony": "Telephony",
    "home_construction": "Home Construction",
    "auto": "Auto",
    "music": "Music",
    "industry_commerce_and_business": "Industry, Commerce & Business",
    "fashion_shoes": "Fashion: Shoes",
    "fashion_sport": "Fashion: Sport",
    "small_appliances": "Small Appliances",
    "fashion_underwear_beach": "Fashion: Underwear & Beach",
    "dvds_blu_ray": "DVDs & Blu-ray",
    "drinks": "Drinks",
    "agro_industry_and_commerce": "Agro Industry & Commerce",
    "arts_and_craftmanship": "Arts & Craftsmanship",
    "books_general_interest": "Books: General Interest",
    "consoles_games": "Consoles & Games",
    "tablets_printing_image": "Tablets, Printing & Image",
    "la_cuisine": "La Cuisine",
    "cds_dvds_musicals": "CDs, DVDs & Musicals",
    "fashion_bags_accessories": "Fashion: Bags & Accessories",
    "garden_tools": "Garden Tools",
    "construction_tools_safety": "Construction Tools: Safety",
    "luggage_accessories": "Luggage & Accessories",
    "construction_tools_lights": "Construction Tools: Lights",
    "furniture_mattress_and_upholstery": "Mattresses & Upholstery",
    "small_appliances_home_oven_and_coffee": "Small Appliances: Oven & Coffee",
    "fashio_female_clothing": "Fashion: Female Clothing",
    "pc_gamer": "PC Gamer",
    "furniture_living_room": "Living Room Furniture",
    "audio": "Audio",
    "watches_gifts": "Watches & Gifts",
    "fashion_male_clothing": "Fashion: Male Clothing",
    "computers": "Computers",
    "pet_shop": "Pet Shop",
    "home_comfort_2": "Home Comfort 2",
    "food_drink": "Food & Drink",
    "furniture_decor": "Furniture & Decor",
    "electronics": "Electronics",
    "flowers": "Flowers",
    "christmas_supplies": "Christmas Supplies",
    "diapers_and_hygiene": "Diapers & Hygiene",
    "home_appliances": "Home Appliances"
}

PAYMENT_LABELS = {
    "credit_card": "Credit Card",
    "boleto": "Boleto",
    "voucher": "Voucher",
    "debit_card": "Debit Card",
    "not_defined": "Not Defined"
}

DELIVERY_BUCKET_ORDER = {
    "< 3 days": 1,
    "3-6 days": 2,
    "7-13 days": 3,
    "14-20 days": 4,
    "21+ days": 5,
    "not_delivered": 6
}

DELIVERY_BUCKET_LABELS = {
    "< 3 days": "< 3 Days",
    "3-6 days": "3-6 Days",
    "7-13 days": "7-13 Days",
    "14-20 days": "14-20 Days",
    "21+ days": "21+ Days",
    "not_delivered": "Not Delivered"
}

CUSTOMER_SEGMENT_LABELS = {
    "high_value_loyal": "High Value Loyal",
    "core_customers": "Core Customers",
    "high_value_one_time": "High Value One-Time",
    "mid_value_one_time": "Mid Value One-Time",
    "low_value_occasional": "Low Value Occasional"
}

REVENUE_SEGMENT_LABELS = {
    "low_value": "Low Value",
    "mid_value": "Mid Value",
    "high_value": "High Value"
}

REVIEW_GROUP_LABELS = {
    "low_reviews": "Low Reviews (<= 2)",
    "normal_reviews": "Normal Reviews (> 2)"
}

# --------------------------------------------------
# Generic helpers
# --------------------------------------------------
@st.cache_data
def load_csv(filename: str) -> pd.DataFrame:
    path = DATA_PATH / filename
    if path.exists():
        return pd.read_csv(path)
    return pd.DataFrame()

@st.cache_data
def load_logo():
    if LOGO_PATH.exists():
        return Image.open(LOGO_PATH)
    return None

@st.cache_data
def load_all_data() -> dict[str, pd.DataFrame]:
    return {key: load_csv(filename) for key, filename in FILES.items()}

def style_axes(ax, title: str, xlabel: str = "", ylabel: str = ""):
    ax.set_title(title, loc="left", pad=12, fontweight="bold")
    ax.set_xlabel(xlabel)
    ax.set_ylabel(ylabel)
    ax.grid(True, axis="y", alpha=0.8)
    ax.spines["top"].set_visible(False)
    ax.spines["right"].set_visible(False)

def format_int(value):
    if pd.isna(value):
        return "-"
    return f"{int(value):,}"

def format_float(value, digits=2):
    if pd.isna(value):
        return "-"
    return f"{value:,.{digits}f}"

def format_currency(value):
    if pd.isna(value):
        return "-"
    return f"${float(value):,.2f}"

def format_percent(value):
    if pd.isna(value):
        return "-"
    return f"{value:.2%}"

def insight(text: str):
    st.markdown(f'<div class="insight-box">{text}</div>', unsafe_allow_html=True)

def human_money_axis(x, pos):
    if abs(x) >= 1_000_000:
        return f"{x / 1_000_000:.1f}M"
    if abs(x) >= 1_000:
        return f"{x / 1_000:.0f}K"
    return f"{x:.0f}"

def filter_by_date_range(df: pd.DataFrame, date_col: str, start_date, end_date) -> pd.DataFrame:
    if df.empty or date_col not in df.columns:
        return df.copy()

    filtered = df.copy()
    filtered[date_col] = pd.to_datetime(filtered[date_col], errors="coerce")
    start_ts = pd.to_datetime(start_date)
    end_ts = pd.to_datetime(end_date)

    return filtered[
        filtered[date_col].between(start_ts, end_ts, inclusive="both")
    ].copy()

def apply_label_map(df: pd.DataFrame, col: str, mapping: dict) -> pd.DataFrame:
    if df.empty or col not in df.columns:
        return df
    out = df.copy()
    out[col] = out[col].map(lambda x: mapping.get(x, str(x).replace("_", " ").title()))
    return out

def format_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    formatted = df.copy()

    for col in formatted.columns:
        col_lower = col.lower()
        is_numeric = pd.api.types.is_numeric_dtype(formatted[col])

        if not is_numeric:
            continue

        if "revenue" in col_lower or "value" in col_lower:
            formatted[col] = formatted[col].map(format_currency)

        elif "rate" in col_lower or "share" in col_lower:
            formatted[col] = formatted[col].map(format_percent)

        elif "days" in col_lower:
            formatted[col] = formatted[col].map(
                lambda x: "-" if pd.isna(x) else f"{x:,.2f}"
            )

        elif "score" in col_lower:
            formatted[col] = formatted[col].map(
                lambda x: "-" if pd.isna(x) else f"{x:,.2f}"
            )

        elif (
            "orders" in col_lower
            or "customers" in col_lower
            or "sellers" in col_lower
            or "items" in col_lower
        ):
            formatted[col] = formatted[col].map(
                lambda x: "-" if pd.isna(x) else f"{int(x):,}"
            )

    return formatted

def show_table(df: pd.DataFrame):
    st.dataframe(format_dataframe(df), use_container_width=True, hide_index=True)

def rename_table(df: pd.DataFrame, mapping: dict[str, str]) -> pd.DataFrame:
    return df.rename(columns=mapping)

def validate_required_files(data: dict[str, pd.DataFrame]):
    missing = [FILES[key] for key in REQUIRED_KEYS if data[key].empty]
    if missing:
        st.error("Some export files are missing or could not be loaded.")
        st.write("Missing files:")
        for file_name in missing:
            st.write(f"- {file_name}")
        st.stop()

# --------------------------------------------------
# Chart helpers
# --------------------------------------------------
def plot_line_chart(
    df: pd.DataFrame,
    x: str,
    y: str,
    title: str,
    xlabel: str,
    ylabel: str,
    *,
    figsize=(8, 4.5),
    marker="o",
    rotate_x=False,
    use_money_axis=False,
    label=None,
):
    fig, ax = plt.subplots(figsize=figsize)
    ax.plot(df[x], df[y], marker=marker, linewidth=2.4, label=label)
    if use_money_axis:
        ax.yaxis.set_major_formatter(FuncFormatter(human_money_axis))
    style_axes(ax, title, xlabel, ylabel)
    if rotate_x:
        plt.xticks(rotation=30, ha="right")
    try:
        fig.autofmt_xdate()
    except Exception:
        pass
    if label:
        plt.legend()
    st.pyplot(fig, use_container_width=True)

def plot_bar_chart(
    df: pd.DataFrame,
    x: str,
    y: str,
    title: str,
    xlabel: str,
    ylabel: str,
    *,
    figsize=(8, 4.5),
    rotate_x=False,
    use_money_axis=False,
):
    fig, ax = plt.subplots(figsize=figsize)
    ax.bar(df[x], df[y], color=PRIMARY_GREEN, edgecolor=DARK_GREEN)
    if use_money_axis:
        ax.yaxis.set_major_formatter(FuncFormatter(human_money_axis))
    style_axes(ax, title, xlabel, ylabel)
    if rotate_x:
        plt.xticks(rotation=30, ha="right")
    st.pyplot(fig, use_container_width=True)

def plot_barh_chart(
    df: pd.DataFrame,
    x: str,
    y: str,
    title: str,
    xlabel: str,
    ylabel: str,
    *,
    figsize=(10, 6.5),
    use_money_axis=False,
):
    fig, ax = plt.subplots(figsize=figsize)
    ax.barh(df[y][::-1], df[x][::-1], color=PRIMARY_GREEN, edgecolor=DARK_GREEN)
    if use_money_axis:
        ax.xaxis.set_major_formatter(FuncFormatter(human_money_axis))
    style_axes(ax, title, xlabel, ylabel)
    st.pyplot(fig, use_container_width=True)

def plot_multi_line(
    df: pd.DataFrame,
    x: str,
    y: str,
    series_col: str,
    title: str,
    xlabel: str,
    ylabel: str,
    *,
    figsize=(10, 5.5),
    use_money_axis=False,
    rotate_x=False,
):
    fig, ax = plt.subplots(figsize=figsize)
    for series in df[series_col].dropna().unique():
        subset = df[df[series_col] == series]
        ax.plot(subset[x], subset[y], marker="o", linewidth=2.0, label=series)

    if use_money_axis:
        ax.yaxis.set_major_formatter(FuncFormatter(human_money_axis))

    style_axes(ax, title, xlabel, ylabel)
    if rotate_x:
        plt.xticks(rotation=25, ha="right")
    try:
        fig.autofmt_xdate()
    except Exception:
        pass
    plt.legend()
    st.pyplot(fig, use_container_width=True)

# --------------------------------------------------
# Data preparation
# --------------------------------------------------
def prepare_data(data: dict[str, pd.DataFrame]) -> dict[str, pd.DataFrame]:
    d = {k: v.copy() for k, v in data.items()}

    # date parsing
    for key in ["delivery_monthly", "customer_segment_monthly"]:
        if "order_month" in d[key].columns:
            d[key]["order_month"] = pd.to_datetime(d[key]["order_month"])

    # basic mappings
    for key in ["category_perf", "product_perf", "category_review"]:
        d[key] = apply_label_map(d[key], "category_name", CATEGORY_LABELS)

    for key in ["payment_mix", "payment_review", "payment_delivery"]:
        d[key] = apply_label_map(d[key], "payment_type", PAYMENT_LABELS)

    # delivery buckets
    for key in ["delivery_buckets", "review_bucket", "review_delivery_combined"]:
        if "delivery_bucket" in d[key].columns:
            d[key]["bucket_order"] = d[key]["delivery_bucket"].map(DELIVERY_BUCKET_ORDER)
            d[key]["delivery_bucket"] = d[key]["delivery_bucket"].map(
                lambda x: DELIVERY_BUCKET_LABELS.get(x, x)
            )
            d[key].sort_values("bucket_order", inplace=True)

    # review late labels
    if "delivery_type" in d["review_late"].columns:
        d["review_late"]["delivery_type"] = d["review_late"]["delivery_type"].replace({
            "late": "Late",
            "on_time_or_early": "On Time or Early"
        })

    if "delivery_type" in d["review_delivery_combined"].columns:
        d["review_delivery_combined"]["delivery_type"] = d["review_delivery_combined"]["delivery_type"].replace({
            "late": "Late",
            "on_time": "On Time"
        })

    d["review_revenue_segment"] = apply_label_map(
        d["review_revenue_segment"], "revenue_segment", REVENUE_SEGMENT_LABELS
    )
    if "delivery_type" in d["review_revenue_segment"].columns:
        d["review_revenue_segment"]["delivery_type"] = d["review_revenue_segment"]["delivery_type"].replace({
            "late": "Late",
            "on_time_or_early": "On Time or Early"
        })

    d["low_review_drivers"] = apply_label_map(
        d["low_review_drivers"], "review_group", REVIEW_GROUP_LABELS
    )

    for key in ["customer_segment_summary", "customer_segment_delivery_review", "customer_segment_monthly", "customer_segments"]:
        d[key] = apply_label_map(d[key], "customer_segment", CUSTOMER_SEGMENT_LABELS)

    return d

# --------------------------------------------------
# Header
# --------------------------------------------------
logo = load_logo()
header_left, header_right = st.columns([1, 5])

with header_left:
    if logo is not None:
        st.image(logo, width=170)

with header_right:
    st.title("Brazilian E-Commerce Analysis Dashboard")
    st.caption(
        "Revenue Distribution · Seller Concentration · Delivery Performance · "
        "Customer Experience · Root Cause Analysis · Customer Segmentation"
    )

# --------------------------------------------------
# Load + prepare
# --------------------------------------------------
data = prepare_data(load_all_data())
validate_required_files(data)

# --------------------------------------------------
# Sidebar
# --------------------------------------------------
st.sidebar.header("Dashboard Navigation")
section = st.sidebar.radio("Select analysis area", PAGE_OPTIONS)
top_n = st.sidebar.slider("Top N rows (table views)", 5, 50, 15)

# --------------------------------------------------
# Time filter
# --------------------------------------------------
filtered_delivery_monthly = data["delivery_monthly"].copy()
filtered_customer_segment_monthly = data["customer_segment_monthly"].copy()

st.sidebar.markdown("---")
st.sidebar.subheader("Time Filter")

date_filter_available = (
    "order_month" in data["delivery_monthly"].columns
    and not data["delivery_monthly"].empty
    and data["delivery_monthly"]["order_month"].notna().any()
)

if date_filter_available:
    min_order_month = data["delivery_monthly"]["order_month"].min().date()
    max_order_month = data["delivery_monthly"]["order_month"].max().date()

    selected_date_range = st.sidebar.date_input(
        "Select order month range",
        value=(min_order_month, max_order_month),
        min_value=min_order_month,
        max_value=max_order_month
    )

    if isinstance(selected_date_range, tuple) and len(selected_date_range) == 2:
        selected_start_date, selected_end_date = selected_date_range
    else:
        selected_start_date, selected_end_date = min_order_month, max_order_month

    filtered_delivery_monthly = filter_by_date_range(
        data["delivery_monthly"], "order_month", selected_start_date, selected_end_date
    )
    filtered_customer_segment_monthly = filter_by_date_range(
        data["customer_segment_monthly"], "order_month", selected_start_date, selected_end_date
    )

    st.sidebar.caption("The current time filter applies to time-based views only.")
else:
    st.sidebar.info("No time-based filter is available for the loaded data.")

# --------------------------------------------------
# Page renderers
# --------------------------------------------------
def render_executive_overview():
    st.subheader("Executive Overview")
    st.markdown(
        '<div class="section-note">This section summarizes the marketplace structure, delivery efficiency, customer experience, and segment-level revenue concentration. The interactive deep dive below allows targeted exploration without changing the rest of the dashboard.</div>',
        unsafe_allow_html=True
    )

    customer_deciles = data["customer_deciles"]
    customer_pareto = data["customer_pareto"]
    seller_pareto = data["seller_pareto"]
    review_score = data["review_score"]
    customer_segment_summary = data["customer_segment_summary"]
    category_perf = data["category_perf"]
    review_revenue_segment = data["review_revenue_segment"]
    customer_segment_delivery_review = data["customer_segment_delivery_review"]

    total_revenue = customer_deciles["revenue"].sum()
    total_customers = customer_pareto["customer_unique_id"].nunique()
    total_sellers = seller_pareto["seller_id"].nunique()
    avg_revenue_per_customer = total_revenue / total_customers if total_customers > 0 else 0
    avg_late_delivery_rate = filtered_delivery_monthly["late_delivery_rate"].mean()
    avg_delivery_days = filtered_delivery_monthly["avg_delivery_days"].mean()
    avg_review_score = (
        (review_score["review_score"] * review_score["orders_count"]).sum()
        / review_score["orders_count"].sum()
    )
    top_segment = customer_segment_summary.iloc[0]["customer_segment"]
    top_segment_revenue_share = customer_segment_summary.iloc[0]["revenue_share"]

    insight(
        f"Total marketplace revenue amounts to {format_currency(total_revenue)}. "
        f"Average delivery time is {format_float(avg_delivery_days)} days, "
        f"the average review score is {format_float(avg_review_score)}, "
        f"and the largest customer segment by revenue is {top_segment} with {format_percent(top_segment_revenue_share)} of total revenue."
    )

    col1, col2, col3, col4 = st.columns(4)
    col1.metric("Total Revenue", format_currency(total_revenue))
    col2.metric("Customers", format_int(total_customers))
    col3.metric("Sellers", format_int(total_sellers))
    col4.metric("Average Revenue per Customer", format_currency(avg_revenue_per_customer))

    col5, col6, col7 = st.columns(3)
    col5.metric("Average Late Delivery Rate", format_percent(avg_late_delivery_rate))
    col6.metric("Average Delivery Time", f"{format_float(avg_delivery_days)} days")
    col7.metric("Average Review Score", format_float(avg_review_score))

    st.markdown("### Interactive Deep Dive")
    st.markdown(
        '<div class="section-note">Use the selectors below to explore categories, customer segments, and revenue segments in a more targeted way.</div>',
        unsafe_allow_html=True
    )

    deep_col1, deep_col2, deep_col3 = st.columns(3)

    with deep_col1:
        category_options = ["All"] + sorted(category_perf["category_name"].dropna().unique().tolist())
        selected_category = st.selectbox("Category", category_options)

    with deep_col2:
        customer_segment_options = ["All"] + sorted(customer_segment_summary["customer_segment"].dropna().unique().tolist())
        selected_customer_segment = st.selectbox("Customer Segment", customer_segment_options)

    with deep_col3:
        revenue_segment_options = ["All"] + sorted(review_revenue_segment["revenue_segment"].dropna().unique().tolist())
        selected_revenue_segment = st.selectbox("Revenue Segment", revenue_segment_options)

    filtered_category_perf = category_perf.copy()
    filtered_customer_segment_summary = customer_segment_summary.copy()
    filtered_customer_segment_delivery = customer_segment_delivery_review.copy()
    filtered_review_revenue_segment = review_revenue_segment.copy()

    if selected_category != "All":
        filtered_category_perf = filtered_category_perf[
            filtered_category_perf["category_name"] == selected_category
        ]

    if selected_customer_segment != "All":
        filtered_customer_segment_summary = filtered_customer_segment_summary[
            filtered_customer_segment_summary["customer_segment"] == selected_customer_segment
        ]
        filtered_customer_segment_delivery = filtered_customer_segment_delivery[
            filtered_customer_segment_delivery["customer_segment"] == selected_customer_segment
        ]

    if selected_revenue_segment != "All":
        filtered_review_revenue_segment = filtered_review_revenue_segment[
            filtered_review_revenue_segment["revenue_segment"] == selected_revenue_segment
        ]

    deep_left, deep_mid, deep_right = st.columns(3)

    with deep_left:
        st.markdown("#### Category Snapshot")
        if not filtered_category_perf.empty:
            show_table(rename_table(
                filtered_category_perf[[
                    "category_name", "gross_revenue", "items_sold", "orders_count", "avg_item_value"
                ]].head(top_n),
                {
                    "category_name": "Category",
                    "gross_revenue": "Gross Revenue",
                    "items_sold": "Items Sold",
                    "orders_count": "Orders",
                    "avg_item_value": "Average Item Value",
                }
            ))
        else:
            st.info("No data available for the selected category.")

    with deep_mid:
        st.markdown("#### Customer Segment Snapshot")
        if not filtered_customer_segment_summary.empty:
            show_table(rename_table(
                filtered_customer_segment_summary,
                {
                    "customer_segment": "Customer Segment",
                    "customers": "Customers",
                    "total_orders": "Total Orders",
                    "total_revenue": "Total Revenue",
                    "avg_revenue_per_customer": "Average Revenue per Customer",
                    "avg_order_value": "Average Order Value",
                    "avg_delivery_days": "Average Delivery Time (Days)",
                    "avg_late_delivery_rate": "Average Late Delivery Rate",
                    "avg_review_score": "Average Review Score",
                    "revenue_share": "Revenue Share",
                    "customer_share": "Customer Share"
                }
            ))
        else:
            st.info("No data available for the selected customer segment.")

    with deep_right:
        st.markdown("#### Revenue Segment Snapshot")
        if not filtered_review_revenue_segment.empty:
            show_table(rename_table(
                filtered_review_revenue_segment,
                {
                    "revenue_segment": "Revenue Segment",
                    "delivery_type": "Delivery Type",
                    "orders_count": "Orders",
                    "avg_review_score": "Average Review Score",
                    "avg_delivery_days": "Average Delivery Time (Days)",
                    "late_delivery_rate": "Late Delivery Rate",
                    "avg_order_value": "Average Order Value",
                }
            ))
        else:
            st.info("No data available for the selected revenue segment.")

    left, right = st.columns(2)

    with left:
        plot_line_chart(
            filtered_delivery_monthly,
            "order_month",
            "avg_delivery_days",
            "Average Delivery Time by Order Month",
            "Order Month",
            "Average Delivery Time (Days)"
        )

    with right:
        plot_bar_chart(
            customer_segment_summary,
            "customer_segment",
            "revenue_share",
            "Revenue Share by Customer Segment",
            "Customer Segment",
            "Revenue Share",
            rotate_x=True
        )

    st.markdown("#### Top Product Categories by Revenue")
    show_table(rename_table(
        category_perf[["category_name", "gross_revenue", "items_sold", "orders_count"]].head(top_n),
        {
            "category_name": "Category",
            "gross_revenue": "Gross Revenue",
            "items_sold": "Items Sold",
            "orders_count": "Orders"
        }
    ))

def render_revenue_distribution():
    customer_deciles = data["customer_deciles"]
    customer_pareto = data["customer_pareto"]

    st.subheader("Revenue Distribution")
    st.markdown(
        '<div class="section-note">This section shows how strongly customer revenue is concentrated and how much value is generated by the highest-spending customer groups.</div>',
        unsafe_allow_html=True
    )

    top_decile_share = customer_deciles.loc[
        customer_deciles["revenue_decile"] == 1, "revenue_share"
    ].iloc[0]

    insight(
        f"The highest customer revenue decile accounts for {format_percent(top_decile_share)} of total revenue, "
        "indicating a pronounced revenue concentration among top-spending customers."
    )

    col1, col2 = st.columns(2)

    with col1:
        fig, ax = plt.subplots(figsize=(8, 4.5))
        ax.plot(
            customer_pareto["cumulative_customer_share"],
            customer_pareto["cumulative_revenue_share"],
            linewidth=2.6,
            color=PRIMARY_GREEN
        )
        ax.plot([0, 1], [0, 1], linestyle="--", linewidth=1.2, color=MID_GREEN)
        style_axes(ax, "Customer Pareto Curve", "Cumulative Share of Customers", "Cumulative Share of Revenue")
        st.pyplot(fig, use_container_width=True)

    with col2:
        plot_bar_chart(
            customer_deciles,
            customer_deciles["revenue_decile"].astype(str).name if False else "revenue_decile",
            "revenue_share",
            "Revenue Share by Customer Decile",
            "Customer Revenue Decile",
            "Revenue Share",
        )

    st.markdown("#### Highest-Revenue Customers")
    customer_display = customer_pareto[[
        "customer_unique_id", "orders_count", "total_revenue", "avg_order_revenue", "cumulative_revenue_share"
    ]].copy()
    customer_display = customer_display[customer_display["total_revenue"].notna()].head(top_n)

    show_table(rename_table(
        customer_display,
        {
            "customer_unique_id": "Customer Unique ID",
            "orders_count": "Orders",
            "total_revenue": "Total Revenue",
            "avg_order_revenue": "Average Order Revenue",
            "cumulative_revenue_share": "Cumulative Revenue Share",
        }
    ))

def render_seller_concentration():
    seller_deciles = data["seller_deciles"]
    seller_pareto = data["seller_pareto"]

    st.subheader("Seller Concentration")
    st.markdown(
        '<div class="section-note">This section evaluates whether marketplace revenue is broadly distributed or driven by a relatively small number of sellers.</div>',
        unsafe_allow_html=True
    )

    top_seller_decile_share = seller_deciles.loc[
        seller_deciles["seller_decile"] == 1, "revenue_share"
    ].iloc[0]

    insight(
        f"The top seller revenue decile contributes {format_percent(top_seller_decile_share)} of total gross revenue, "
        "showing a substantial concentration of seller performance."
    )

    col1, col2 = st.columns(2)

    with col1:
        fig, ax = plt.subplots(figsize=(8, 4.5))
        ax.plot(
            seller_pareto["cumulative_seller_share"],
            seller_pareto["cumulative_revenue_share"],
            linewidth=2.6,
            color=PRIMARY_GREEN
        )
        ax.plot([0, 1], [0, 1], linestyle="--", linewidth=1.2, color=MID_GREEN)
        style_axes(ax, "Seller Pareto Curve", "Cumulative Share of Sellers", "Cumulative Share of Revenue")
        st.pyplot(fig, use_container_width=True)

    with col2:
        plot_bar_chart(
            seller_deciles,
            "seller_decile",
            "revenue_share",
            "Revenue Share by Seller Decile",
            "Seller Revenue Decile",
            "Revenue Share",
        )

    st.markdown("#### Top Sellers by Revenue")
    show_table(rename_table(
        seller_pareto[[
            "seller_id", "seller_city", "seller_state", "orders_count", "items_sold", "gross_revenue"
        ]].head(top_n),
        {
            "seller_id": "Seller ID",
            "seller_city": "Seller City",
            "seller_state": "Seller State",
            "orders_count": "Orders",
            "items_sold": "Items Sold",
            "gross_revenue": "Gross Revenue"
        }
    ))

def render_delivery_performance():
    delivery_status = data["delivery_status"]
    delivery_buckets = data["delivery_buckets"]

    st.subheader("Delivery Performance")
    st.markdown(
        '<div class="section-note">This section focuses on delivery speed, late delivery patterns, and operational consistency over time.</div>',
        unsafe_allow_html=True
    )

    delivered_row = delivery_status[delivery_status["order_status"] == "delivered"]
    if not delivered_row.empty:
        delivered_late_rate = delivered_row["late_delivery_rate"].iloc[0]
        delivered_days = delivered_row["avg_delivery_days"].iloc[0]
        insight(
            f"Delivered orders take {format_float(delivered_days)} days on average, "
            f"with a late-delivery rate of {format_percent(delivered_late_rate)}."
        )

    col1, col2 = st.columns(2)

    with col1:
        plot_line_chart(
            filtered_delivery_monthly,
            "order_month",
            "avg_delivery_days",
            "Average Delivery Time by Month",
            "Order Month",
            "Average Delivery Time (Days)"
        )

    with col2:
        plot_line_chart(
            filtered_delivery_monthly,
            "order_month",
            "late_delivery_rate",
            "Late Delivery Rate by Month",
            "Order Month",
            "Late Delivery Rate"
        )

    col3, col4 = st.columns(2)

    with col3:
        plot_bar_chart(
            delivery_buckets,
            "delivery_bucket",
            "orders_count",
            "Distribution of Orders Across Delivery Time Buckets",
            "Delivery Time Bucket",
            "Number of Orders",
            rotate_x=True
        )

    with col4:
        st.markdown("#### Delivery Metrics by Order Status")
        show_table(rename_table(
            delivery_status[[
                "order_status", "orders_count", "avg_delivery_days", "late_delivery_rate"
            ]],
            {
                "order_status": "Order Status",
                "orders_count": "Orders",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "late_delivery_rate": "Late Delivery Rate"
            }
        ))

def render_review_vs_delivery():
    review_late = data["review_late"]
    review_score = data["review_score"]
    review_bucket = data["review_bucket"]

    st.subheader("Review vs Delivery")
    st.markdown(
        '<div class="section-note">This section examines the relationship between customer satisfaction and operational delivery outcomes.</div>',
        unsafe_allow_html=True
    )

    late_row = review_late[review_late["delivery_type"] == "Late"]
    ontime_row = review_late[review_late["delivery_type"] == "On Time or Early"]

    if not late_row.empty and not ontime_row.empty:
        late_score = late_row["avg_review_score"].iloc[0]
        ontime_score = ontime_row["avg_review_score"].iloc[0]
        insight(
            f"Late deliveries receive an average review score of {format_float(late_score)}, "
            f"compared with {format_float(ontime_score)} for on-time or early deliveries."
        )

    col1, col2 = st.columns(2)

    with col1:
        plot_line_chart(
            review_score,
            "review_score",
            "avg_delivery_days",
            "Average Delivery Time by Review Score",
            "Review Score",
            "Average Delivery Time (Days)"
        )

    with col2:
        plot_line_chart(
            review_score,
            "review_score",
            "late_delivery_rate",
            "Late Delivery Rate by Review Score",
            "Review Score",
            "Late Delivery Rate"
        )

    col3, col4 = st.columns(2)

    with col3:
        plot_bar_chart(
            review_bucket,
            "delivery_bucket",
            "avg_review_score",
            "Average Review Score Across Delivery Time Buckets",
            "Delivery Time Bucket",
            "Average Review Score",
            rotate_x=True
        )

    with col4:
        st.markdown("#### Late vs On-Time Delivery Comparison")
        show_table(rename_table(
            review_late,
            {
                "delivery_type": "Delivery Type",
                "orders_count": "Orders",
                "avg_review_score": "Average Review Score",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "avg_order_revenue": "Average Order Revenue"
            }
        ))

def render_root_cause_analysis():
    low_review_drivers = data["low_review_drivers"]
    review_revenue_segment = data["review_revenue_segment"]
    review_delivery_combined = data["review_delivery_combined"]

    st.subheader("Root Cause Analysis")
    st.markdown(
        '<div class="section-note">This section focuses on the likely drivers of poor reviews by combining delivery speed, delay patterns, and order value segmentation.</div>',
        unsafe_allow_html=True
    )

    low_reviews_row = low_review_drivers[low_review_drivers["review_group"] == "Low Reviews (<= 2)"]
    normal_reviews_row = low_review_drivers[low_review_drivers["review_group"] == "Normal Reviews (> 2)"]

    if not low_reviews_row.empty and not normal_reviews_row.empty:
        low_late_rate = low_reviews_row["late_rate"].iloc[0]
        normal_late_rate = normal_reviews_row["late_rate"].iloc[0]
        insight(
            f"Orders with low review scores show a late-delivery rate of {format_percent(low_late_rate)}, "
            f"compared with {format_percent(normal_late_rate)} for normal reviews. "
            "This indicates that delivery reliability is a major driver of customer dissatisfaction."
        )

    col1, col2 = st.columns(2)

    with col1:
        st.markdown("#### Low Review Drivers")
        show_table(rename_table(
            low_review_drivers,
            {
                "review_group": "Review Group",
                "orders_count": "Orders",
                "avg_review_score": "Average Review Score",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "avg_delay_days": "Average Delay (Days)",
                "late_rate": "Late Delivery Rate",
                "avg_order_value": "Average Order Value"
            }
        ))

    with col2:
        plot_bar_chart(
            low_review_drivers,
            "review_group",
            "late_rate",
            "Late Delivery Rate by Review Group",
            "Review Group",
            "Late Delivery Rate",
            rotate_x=True
        )

    st.markdown("#### Delivery Impact by Revenue Segment")
    left, right = st.columns(2)

    with left:
        pivot_reviews = review_revenue_segment.pivot(
            index="revenue_segment",
            columns="delivery_type",
            values="avg_review_score"
        ).fillna(0)

        fig, ax = plt.subplots(figsize=(8, 4.5))
        pivot_reviews.plot(kind="bar", ax=ax, edgecolor=DARK_GREEN)
        style_axes(ax, "Average Review Score by Revenue Segment and Delivery Type", "Revenue Segment", "Average Review Score")
        plt.xticks(rotation=20, ha="right")
        plt.legend(title="Delivery Type")
        st.pyplot(fig, use_container_width=True)

    with right:
        show_table(rename_table(
            review_revenue_segment,
            {
                "revenue_segment": "Revenue Segment",
                "delivery_type": "Delivery Type",
                "orders_count": "Orders",
                "avg_review_score": "Average Review Score",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "late_delivery_rate": "Late Delivery Rate",
                "avg_order_value": "Average Order Value"
            }
        ))

    st.markdown("#### Combined Delivery Bucket and Delivery Status")
    plot_multi_line(
        review_delivery_combined,
        "delivery_bucket",
        "avg_review_score",
        "delivery_type",
        "Average Review Score by Delivery Bucket and Delivery Status",
        "Delivery Bucket",
        "Average Review Score",
        rotate_x=True
    )

def render_customer_segmentation():
    customer_segment_summary = data["customer_segment_summary"]
    customer_segment_delivery_review = data["customer_segment_delivery_review"]

    st.subheader("Customer Segmentation")
    st.markdown(
        '<div class="section-note">This section segments customers by value and purchase frequency to highlight which groups drive revenue and how their delivery and review patterns differ.</div>',
        unsafe_allow_html=True
    )

    top_segment = customer_segment_summary.iloc[0]["customer_segment"]
    top_segment_revenue = customer_segment_summary.iloc[0]["total_revenue"]

    insight(
        f"The highest-value segment is {top_segment}, generating total revenue of {format_currency(top_segment_revenue)}. "
        "This helps distinguish core business drivers from lower-value occasional customers."
    )

    col1, col2 = st.columns(2)

    with col1:
        plot_bar_chart(
            customer_segment_summary,
            "customer_segment",
            "total_revenue",
            "Total Revenue by Customer Segment",
            "Customer Segment",
            "Total Revenue",
            rotate_x=True,
            use_money_axis=True
        )

    with col2:
        plot_bar_chart(
            customer_segment_summary,
            "customer_segment",
            "avg_review_score",
            "Average Review Score by Customer Segment",
            "Customer Segment",
            "Average Review Score",
            rotate_x=True
        )

    col3, col4 = st.columns(2)

    with col3:
        st.markdown("#### Segment Summary")
        show_table(rename_table(
            customer_segment_summary,
            {
                "customer_segment": "Customer Segment",
                "customers": "Customers",
                "total_orders": "Total Orders",
                "total_revenue": "Total Revenue",
                "avg_revenue_per_customer": "Average Revenue per Customer",
                "avg_order_value": "Average Order Value",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "avg_late_delivery_rate": "Average Late Delivery Rate",
                "avg_review_score": "Average Review Score",
                "revenue_share": "Revenue Share",
                "customer_share": "Customer Share"
            }
        ))

    with col4:
        st.markdown("#### Delivery & Review by Segment")
        show_table(rename_table(
            customer_segment_delivery_review,
            {
                "customer_segment": "Customer Segment",
                "orders_count": "Orders",
                "avg_order_value": "Average Order Value",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "avg_delivery_delay_days": "Average Delay (Days)",
                "late_delivery_rate": "Late Delivery Rate",
                "avg_review_score": "Average Review Score"
            }
        ))

    st.markdown("#### Monthly Revenue Trend by Customer Segment")
    plot_multi_line(
        filtered_customer_segment_monthly,
        "order_month",
        "total_revenue",
        "customer_segment",
        "Monthly Revenue by Customer Segment",
        "Order Month",
        "Total Revenue",
        use_money_axis=True
    )

def render_product_and_category():
    category_perf = data["category_perf"]
    product_perf = data["product_perf"]
    category_review = data["category_review"]

    st.subheader("Product & Category")
    st.markdown(
        '<div class="section-note">This section highlights the strongest product categories, product-level revenue drivers, and category-specific customer review outcomes.</div>',
        unsafe_allow_html=True
    )

    category_top_n = st.slider("Top categories to display", 5, 30, 15)

    if not category_perf.empty:
        top_category = category_perf.iloc[0]["category_name"]
        top_category_revenue = category_perf.iloc[0]["gross_revenue"]
        insight(
            f"The highest-revenue product category is {top_category} with gross revenue of {format_currency(top_category_revenue)}."
        )

    plot_barh_chart(
        category_perf.head(category_top_n),
        "gross_revenue",
        "category_name",
        "Top Product Categories by Gross Revenue",
        "Gross Revenue",
        "Product Category",
        use_money_axis=True
    )

    st.markdown("#### Category-Level Review Performance")
    show_table(rename_table(
        category_review.head(top_n),
        {
            "category_name": "Category",
            "reviewed_orders": "Reviewed Orders",
            "avg_review_score": "Average Review Score",
            "avg_item_value": "Average Item Value"
        }
    ))

    st.markdown("#### Highest-Revenue Products")
    show_table(rename_table(
        product_perf[[
            "product_id", "category_name", "items_sold", "orders_count", "gross_revenue", "avg_item_value"
        ]].head(top_n),
        {
            "product_id": "Product ID",
            "category_name": "Category",
            "items_sold": "Items Sold",
            "orders_count": "Orders",
            "gross_revenue": "Gross Revenue",
            "avg_item_value": "Average Item Value"
        }
    ))

def render_payment_analysis():
    payment_mix = data["payment_mix"]
    payment_installments = data["payment_installments"]
    payment_review = data["payment_review"]
    payment_delivery = data["payment_delivery"]

    st.subheader("Payment Analysis")
    st.markdown(
        '<div class="section-note">This section shows how customers pay, how installments are used, and whether payment types differ in review and delivery outcomes.</div>',
        unsafe_allow_html=True
    )

    if not payment_mix.empty:
        top_payment_type = payment_mix.iloc[0]["payment_type"]
        top_payment_value = payment_mix.iloc[0]["total_payment_value"]
        insight(
            f"The dominant payment method is {top_payment_type}, accounting for total payment value of {format_currency(top_payment_value)}."
        )

    col1, col2 = st.columns(2)

    with col1:
        plot_bar_chart(
            payment_mix,
            "payment_type",
            "total_payment_value",
            "Total Payment Value by Payment Type",
            "Payment Type",
            "Total Payment Value",
            rotate_x=True,
            use_money_axis=True
        )

    with col2:
        installments_filtered = payment_installments[
            payment_installments["payment_installments"] <= 12
        ].copy()

        plot_bar_chart(
            installments_filtered,
            "payment_installments",
            "payment_rows",
            "Distribution of Payment Installments (1-12)",
            "Number of Installments",
            "Number of Payment Rows"
        )

    col3, col4 = st.columns(2)

    with col3:
        st.markdown("#### Review Metrics by Payment Type")
        show_table(rename_table(
            payment_review,
            {
                "payment_type": "Payment Type",
                "reviewed_orders": "Reviewed Orders",
                "avg_review_score": "Average Review Score",
                "avg_payment_value": "Average Payment Value"
            }
        ))

    with col4:
        st.markdown("#### Delivery Metrics by Payment Type")
        show_table(rename_table(
            payment_delivery,
            {
                "payment_type": "Payment Type",
                "orders_count": "Orders",
                "avg_delivery_days": "Average Delivery Time (Days)",
                "late_delivery_rate": "Late Delivery Rate"
            }
        ))

# --------------------------------------------------
# Render selected page
# --------------------------------------------------
PAGE_RENDERERS = {
    "Executive Overview": render_executive_overview,
    "Revenue Distribution": render_revenue_distribution,
    "Seller Concentration": render_seller_concentration,
    "Delivery Performance": render_delivery_performance,
    "Review vs Delivery": render_review_vs_delivery,
    "Root Cause Analysis": render_root_cause_analysis,
    "Customer Segmentation": render_customer_segmentation,
    "Product & Category": render_product_and_category,
    "Payment Analysis": render_payment_analysis,
}

PAGE_RENDERERS[section]()

# --------------------------------------------------
# Footer
# --------------------------------------------------
st.markdown("---")
st.caption(f"Data source folder: {DATA_PATH}")