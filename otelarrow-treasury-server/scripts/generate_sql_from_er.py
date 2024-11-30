# Made by Claude, with multiple modifications by me.
import re


def parse_er_diagram(content: str) -> dict[str, dict[str, list[str]]]:
    """Parse Mermaid ER diagram content into a structured format."""
    tables: dict[str, dict[str, list[str]]] = {}
    current_table = None

    content = content.replace("erDiagram\n", "")

    lines = content.strip().split("\n")

    for line in lines:
        line = line.strip()

        if "||--o{" in line or not line:
            continue

        if "{" in line:
            current_table = line.split("{")[0].strip()
            tables[current_table] = {"columns": []}
            continue

        if line == "}":
            current_table = None
            continue

        if current_table and line:
            column_def = line.strip()
            if column_def:
                tables[current_table]["columns"].append(column_def)

    return tables


def map_type_to_duckdb(type_str: str) -> str:
    """Map ER diagram types to DuckDB types."""
    type_mapping = {
        "u8": "UTINYINT",
        "u16": "USMALLINT",
        "u32": "UINTEGER",
        "u64": "UHUGEINT",
        "i32": "INTEGER",
        "i64": "BIGINT",
        "f64": "DOUBLE",
        "string": "VARCHAR",
        "bool": "BOOLEAN",
        "timestamp": "TIMESTAMP",
        "duration": "INTERVAL",
        "bytes": "BLOB",
        "bytes[8]": "UBIGINT",
        "bytes[16]": "UHUGEINT",
    }
    return type_mapping.get(type_str, "VARCHAR")


def generate_create_table_sql(tables: dict[str, dict[str, list[str]]]) -> str:
    """Generate DuckDB CREATE TABLE statements from parsed table definitions."""
    sql_statements: list[str] = []

    for table_name, table_info in tables.items():
        columns: list[str] = []

        for column_def in table_info["columns"]:
            parts = column_def.split()
            if len(parts) < 2:
                continue

            column_name = parts[0]
            data_type = parts[1]

            is_optional = "optional" in column_def

            duckdb_type = map_type_to_duckdb(data_type)

            column_sql = f'"{column_name}" {duckdb_type}'
            if not is_optional:
                column_sql += " NOT NULL"

            columns.append(column_sql)

        create_table = f"""CREATE TABLE {table_name} (
    {',\n    '.join(columns)}
);"""
        sql_statements.append(create_table)

    return "\n\n".join(sql_statements)


def process_content(content: str) -> str:
    """Process the entire content and extract all ER diagrams."""
    er_blocks = re.findall(r"erDiagram.*?```", content, re.DOTALL)

    all_tables: dict[str, dict[str, list[str]]] = {}
    for block in er_blocks:
        block = block.replace("```", "").strip()
        tables = parse_er_diagram(block)
        all_tables.update(tables)

    return generate_create_table_sql(all_tables)


def main():
    with open("er_diagram.md", "r") as f:
        content = f.read()

    sql_output = process_content(content)

    with open("schema.sql", "w") as f:
        f.write(sql_output)


if __name__ == "__main__":
    main()
