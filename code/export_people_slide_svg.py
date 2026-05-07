from __future__ import annotations

from pathlib import Path
import re
import xml.etree.ElementTree as ET


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "resources" / "people_slide.qmd"
OUTPUT = ROOT / "resources" / "people_slide.svg"

IMG_RE = re.compile(r'<img\s+src="([^"]+)"\s+style="([^"]+)"[^>]*>')
STYLE_RE = re.compile(r"([\w-]+)\s*:\s*([^;]+)")


def parse_style(style: str) -> dict[str, str]:
    return {match.group(1): match.group(2).strip() for match in STYLE_RE.finditer(style)}


def read_svg_fragment(path: Path) -> tuple[str, str, str]:
    tree = ET.parse(path)
    root = tree.getroot()
    width = root.attrib.get("width", "100")
    height = root.attrib.get("height", "100")
    inner = "".join(ET.tostring(child, encoding="unicode") for child in list(root))
    return width, height, inner


def main() -> None:
    source_text = SOURCE.read_text(encoding="utf-8")
    matches = list(IMG_RE.finditer(source_text))

    svg_parts = [
        '<?xml version="1.0" encoding="UTF-8"?>',
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="1000" height="1000" role="img" aria-label="People slide">',
    ]

    for match in matches:
        src = match.group(1)
        style = parse_style(match.group(2))

        left = style.get("left", "0").rstrip("%")
        top = style.get("top", "0").rstrip("%")
        width = style.get("width", "0").rstrip("%")
        filter_value = style.get("filter", "")

        icon_path = ROOT / src
        icon_width, icon_height, inner_svg = read_svg_fragment(icon_path)

        try:
            icon_width_value = float(icon_width)
            icon_height_value = float(icon_height)
            width_value = float(width)
            height_value = width_value * icon_height_value / icon_width_value
        except ValueError:
            width_value = 5.0
            height_value = 5.0

        svg_parts.append(
            f'<svg x="{left}" y="{top}" width="{width_value:.3f}" height="{height_value:.3f}" '
            f'viewBox="0 0 {icon_width} {icon_height}" style="overflow:visible;{f"filter:{filter_value};" if filter_value else ""}">'
            f"{inner_svg}"
            f"</svg>"
        )

    svg_parts.append("</svg>")
    OUTPUT.write_text("\n".join(svg_parts) + "\n", encoding="utf-8")
    print(f"Wrote {OUTPUT.relative_to(ROOT)} with {len(matches)} people")


if __name__ == "__main__":
    main()