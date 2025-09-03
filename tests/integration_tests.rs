use gdscript_formatter::format_gdscript;
use similar::{ChangeTag, TextDiff};
use std::fs;
use std::path::Path;

fn make_whitespace_visible(s: &str) -> String {
    s.replace(' ', "·")
        .replace('\t', "⇥   ")
        .replace('\n', "↲\n")
}

fn assert_formatted_eq(result: &str, expected: &str, file_path: &Path) {
    if result != expected {
        eprintln!(
            "\nFormatted output doesn't match expected for {}",
            file_path.display()
        );
        eprintln!("Diff between expected(-) and formatted output(+):");
        let diff = TextDiff::from_lines(expected, result);
        for change in diff.iter_all_changes() {
            let text = make_whitespace_visible(&change.to_string());
            match change.tag() {
                ChangeTag::Insert => eprint!("\x1B[92m+{}\x1B[0m", text),
                ChangeTag::Delete => eprint!("\x1B[91m-{}\x1B[0m", text),
                ChangeTag::Equal => eprint!(" {}", text),
            }
        }
        eprintln!("\nRaw strings:");
        eprintln!("\nEXPECTED (raw):");
        eprintln!("{:?}", expected);
        eprintln!("\nGOT (raw):");
        eprintln!("{:?}", result);
        panic!("Assertion failed");
    }
}

test_each_file::test_each_path! { in "./tests/input" => test_file }

fn test_file(file_path: &Path) {
    let file_name = file_path.file_name().expect("path is not a file path");

    let input_path = file_path;
    let expected_path = file_path
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("expected/")
        .join(file_name);

    let input_content =
        fs::read_to_string(&input_path).expect(&format!("Failed to read {}", input_path.display()));
    let expected_content = fs::read_to_string(&expected_path)
        .expect(&format!("Failed to read {}", expected_path.display()));

    let result = format_gdscript(&input_content)
        .expect(&format!("Failed to format {}", input_path.display()));

    assert_formatted_eq(&result, &expected_content, &input_path);
}
