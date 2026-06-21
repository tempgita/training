"""Generate the two-page weighted population report from Stata CSV outputs."""

import csv
import os
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import mm
from reportlab.platypus import (
    BaseDocTemplate,
    Frame,
    KeepTogether,
    PageBreak,
    PageTemplate,
    Paragraph,
    Spacer,
    Table,
    TableStyle,
)


ROOT = Path(__file__).resolve().parent
OUTPUT = ROOT / "output" / "pdf" / "weighted_population_report.pdf"
NAVY = colors.HexColor("#18324A")
BLUE = colors.HexColor("#247BA0")
PALE = colors.HexColor("#EAF2F7")
INK = colors.HexColor("#24313A")
MUTED = colors.HexColor("#5D6B75")


def read_csv(name):
    with (ROOT / name).open(encoding="utf-8-sig", newline="") as handle:
        return list(csv.DictReader(handle))


overall = read_csv("weighted_population_results.csv")
province = read_csv("weighted_population_by_province.csv")
residence = read_csv("weighted_population_by_residence.csv")
totals = {row["population"]: float(row["weighted_total"]) for row in overall}
households = totals["Households"]
individuals = totals["Individuals"]


styles = getSampleStyleSheet()
styles.add(ParagraphStyle(name="Title2", parent=styles["Title"], fontName="Helvetica-Bold", fontSize=21, leading=24, textColor=NAVY, spaceAfter=4))
styles.add(ParagraphStyle(name="Subtitle", parent=styles["Normal"], fontName="Helvetica", fontSize=9, leading=12, textColor=MUTED, spaceAfter=10))
styles.add(ParagraphStyle(name="H1x", parent=styles["Heading1"], fontName="Helvetica-Bold", fontSize=12, leading=15, textColor=NAVY, spaceBefore=7, spaceAfter=5))
styles.add(ParagraphStyle(name="Bodyx", parent=styles["BodyText"], fontName="Helvetica", fontSize=8.7, leading=12.2, textColor=INK, spaceAfter=5))
styles.add(ParagraphStyle(name="Smallx", parent=styles["BodyText"], fontName="Helvetica", fontSize=7.7, leading=10.2, textColor=INK))
styles.add(ParagraphStyle(name="CardNum", parent=styles["Normal"], fontName="Helvetica-Bold", fontSize=18, leading=20, alignment=TA_CENTER, textColor=NAVY))
styles.add(ParagraphStyle(name="CardLabel", parent=styles["Normal"], fontName="Helvetica", fontSize=7.5, leading=9, alignment=TA_CENTER, textColor=MUTED))
styles.add(ParagraphStyle(name="Callout", parent=styles["BodyText"], fontName="Helvetica-Bold", fontSize=9, leading=12, textColor=NAVY, leftIndent=7, rightIndent=7, spaceBefore=4, spaceAfter=4))


def footer(canvas, doc):
    canvas.saveState()
    width, _ = A4
    canvas.setStrokeColor(colors.HexColor("#CBD7DF"))
    canvas.line(18 * mm, 14 * mm, width - 18 * mm, 14 * mm)
    canvas.setFont("Helvetica", 7)
    canvas.setFillColor(MUTED)
    canvas.drawString(18 * mm, 9.5 * mm, "Weighted population estimates | poverty.dta | Stata 18")
    canvas.drawRightString(width - 18 * mm, 9.5 * mm, f"Page {doc.page}")
    canvas.restoreState()


def fmt(value):
    return f"{float(value):,.0f}"


def p(text, style="Bodyx"):
    return Paragraph(text, styles[style])


def styled_table(data, widths, header=True, font_size=7.6):
    table = Table(data, colWidths=widths, repeatRows=1 if header else 0, hAlign="LEFT")
    commands = [
        ("FONTNAME", (0, 0), (-1, -1), "Helvetica"),
        ("FONTSIZE", (0, 0), (-1, -1), font_size),
        ("LEADING", (0, 0), (-1, -1), font_size + 2.5),
        ("TEXTCOLOR", (0, 0), (-1, -1), INK),
        ("GRID", (0, 0), (-1, -1), 0.35, colors.HexColor("#CCD7DE")),
        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
        ("LEFTPADDING", (0, 0), (-1, -1), 5),
        ("RIGHTPADDING", (0, 0), (-1, -1), 5),
        ("TOPPADDING", (0, 0), (-1, -1), 4),
        ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
        ("ALIGN", (1, 1), (-1, -1), "RIGHT"),
    ]
    if header:
        commands += [
            ("BACKGROUND", (0, 0), (-1, 0), NAVY),
            ("TEXTCOLOR", (0, 0), (-1, 0), colors.white),
            ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
        ]
    for row in range(1 if header else 0, len(data)):
        if row % 2 == 0:
            commands.append(("BACKGROUND", (0, row), (-1, row), colors.HexColor("#F5F8FA")))
    table.setStyle(TableStyle(commands))
    return table


OUTPUT.parent.mkdir(parents=True, exist_ok=True)
doc = BaseDocTemplate(
    str(OUTPUT),
    pagesize=A4,
    leftMargin=18 * mm,
    rightMargin=18 * mm,
    topMargin=16 * mm,
    bottomMargin=19 * mm,
    title="Weighted Population of Individuals and Households",
    author="Reproducible Stata analysis",
)
frame = Frame(doc.leftMargin, doc.bottomMargin, doc.width, doc.height, id="main")
doc.addPageTemplates(PageTemplate(id="report", frames=frame, onPage=footer))

story = []
story.append(p("Weighted Population of Individuals and Households", "Title2"))
story.append(p("A reproducible analysis of poverty.dta | Estimates expanded from 9,600 sampled households", "Subtitle"))

cards = Table(
    [
        [p(fmt(households), "CardNum"), p(fmt(individuals), "CardNum"), p(f"{individuals / households:.3f}", "CardNum")],
        [p("WEIGHTED HOUSEHOLDS", "CardLabel"), p("WEIGHTED INDIVIDUALS", "CardLabel"), p("PERSONS PER HOUSEHOLD", "CardLabel")],
    ],
    colWidths=[doc.width / 3] * 3,
)
cards.setStyle(TableStyle([
    ("BACKGROUND", (0, 0), (-1, -1), PALE),
    ("BOX", (0, 0), (-1, -1), 0.6, colors.HexColor("#B9CEDA")),
    ("INNERGRID", (0, 0), (-1, -1), 0.6, colors.HexColor("#B9CEDA")),
    ("TOPPADDING", (0, 0), (-1, 0), 9),
    ("BOTTOMPADDING", (0, 1), (-1, 1), 8),
]))
story += [cards, Spacer(1, 5)]

story.append(p("Purpose and key result", "H1x"))
story.append(p(
    "The objective is to estimate the national populations represented by the household records. Summing the supplied expansion factors gives <b>7,185,102.7 households</b> and <b>28,740,503.5 individuals</b>. Rounded to countable units, these are 7,185,103 households and 28,740,504 individuals. The ratio of the two unrounded totals is 4.000 persons per household."
))

story.append(p("Variables used", "H1x"))
variable_data = [
    ["Variable", "Role in calculation"],
    ["psu_number + hh_number", "Composite identifier; verified as unique, confirming one record per household."],
    ["hhsize", "Number of usual household members represented by a sampled household."],
    ["hhs_wt", "Census-2021-adjusted household expansion weight; one row represents this many households."],
    ["ind_wt", "Individual expansion weight; dataset label defines it as adjusted household weight x household size."],
]
story.append(styled_table(variable_data, [43 * mm, doc.width - 43 * mm], font_size=7.4))

story.append(p("How the weights are calculated", "H1x"))
story.append(p(
    "Let <i>w</i><sub>h</sub> be <b>hhs_wt</b> for sampled household <i>h</i>, and let <i>m</i><sub>h</sub> be <b>hhsize</b>. The file supplies the person expansion weight as <i>w</i><sub>h</sub><i>m</i><sub>h</sub>. This identity was checked for every record within a relative tolerance of 0.000001 to allow float-storage rounding."
))
formula = Table([[p("Households = &Sigma;<sub>h</sub> w<sub>h</sub> &nbsp;&nbsp;&nbsp; | &nbsp;&nbsp;&nbsp; Individuals = &Sigma;<sub>h</sub> (w<sub>h</sub> x m<sub>h</sub>) = &Sigma;<sub>h</sub> ind_wt", "Callout")]], colWidths=[doc.width])
formula.setStyle(TableStyle([("BACKGROUND", (0, 0), (-1, -1), PALE), ("BOX", (0, 0), (-1, -1), 0.6, BLUE), ("VALIGN", (0, 0), (-1, -1), "MIDDLE")]))
story.append(formula)

story.append(p("Methodology", "H1x"))
story.append(p(
    "The Stata program <b>expansion_total</b> creates an indicator equal to one and estimates its total using the requested weight as a probability weight. The point estimate is the sum of the expansion weights. The do-file first validates unique household IDs, complete inputs, positive weights, household size of at least one, and the construction of <b>ind_wt</b>. It then estimates both national totals and exports exact, unrounded CSV results and diagnostic breakdowns."
))

story.append(PageBreak())
story.append(p("Breakdowns and Interpretation", "Title2"))
story.append(p("Rounded estimates; national totals may differ by one unit from displayed row sums because rounding occurs after estimation.", "Subtitle"))

story.append(p("Province profile", "H1x"))
province_data = [["Province", "Households", "Individuals", "Persons / HH"]]
for row in province:
    hh = float(row["weighted_households"])
    ind = float(row["weighted_individuals"])
    province_data.append([row["province"], fmt(hh), fmt(ind), f"{ind / hh:.2f}"])
province_data.append(["National", fmt(households), fmt(individuals), f"{individuals / households:.2f}"])
province_table = styled_table(province_data, [48 * mm, 41 * mm, 44 * mm, 31 * mm], font_size=7.5)
province_table.setStyle(TableStyle([("FONTNAME", (0, -1), (-1, -1), "Helvetica-Bold"), ("BACKGROUND", (0, -1), (-1, -1), PALE)]))
story.append(province_table)

story.append(p("Residence profile", "H1x"))
residence_data = [["Residence", "Households", "Individuals", "Share of individuals"]]
for row in residence:
    hh = float(row["weighted_households"])
    ind = float(row["weighted_individuals"])
    residence_data.append([row["residence"], fmt(hh), fmt(ind), f"{100 * ind / individuals:.1f}%"])
story.append(styled_table(residence_data, [48 * mm, 38 * mm, 43 * mm, 35 * mm], font_size=7.5))

story.append(p("Interpretation", "H1x"))
story.append(p(
    "Each sampled household represents many households with similar survey-design characteristics. Therefore, the unweighted sample count of 9,600 must not be read as the household population. Bagmati has the largest estimated household population (1.62 million), while Madhesh has the largest estimated individual population (6.49 million). This difference reflects household size: the implied average is about 4.81 persons in Madhesh versus 3.62 in Bagmati. Other urban areas account for 58.7% of represented individuals, rural areas 30.5%, and Kathmandu 10.8%."
))
story.append(p(
    "These are expansion totals for the target population encoded by the provided weights. The household weight label states that it was adjusted to the final 2021 census household count. The file does not provide strata or full documentation of nonresponse and calibration procedures, so this analysis does not reconstruct the original weight-development process or report design-based standard errors."
))

qa = [
    ["Quality check", "Result"],
    ["Household identifier", "psu_number + hh_number uniquely identifies all 9,600 records"],
    ["Missing calculation inputs", "None"],
    ["Positive weights / hhsize >= 1", "Passed for every record"],
    ["ind_wt = hhs_wt x hhsize", "Passed within stated float-rounding tolerance"],
]
story.append(p("Reproducibility and checks", "H1x"))
story.append(styled_table(qa, [52 * mm, doc.width - 52 * mm], font_size=7.2))
story.append(Spacer(1, 4))
story.append(p(
    "Run from this folder with: <font name='Courier'>StataMP-64.exe /e do weighted_population.do</font>. Outputs are <b>weighted_population.log</b>, <b>weighted_population_results.csv</b>, and the province and residence CSV files. The log is the audit record; the do-file contains detailed line-level comments.",
    "Smallx",
))

doc.build(story)
print(OUTPUT)
