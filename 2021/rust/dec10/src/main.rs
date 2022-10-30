/*
chunks: (), [], {}, <>
line contains chunks,
chunks can contain other chunks
lines can be complete, incomplete, or corrupted
*/
fn main() {
    println!("Dec10");
    process_line(&"{{}{{{}}{}}{}}");
}

fn process_line(line: &str) {
    let chars: Vec<char> = line.trim().chars().collect();
    println!("{:?}", chars);
    let left = process_chunks(chars[0], &chars[1..]);
    println!("All left: {:?}", left);
}

enum Result {
    Complete,
    Incomplete,
    Corrupt
}

fn process_chunks(head: char, tail: &[char]) -> &[char] {
    //if tail.len() < 1 { return &tail[..]; }

    if is_opening(head) {
        if is_closing(head, tail[0]) {
            return &tail[1..];
        } else {
            let left = process_chunks(tail[0], &tail[1..]);
            if is_closing(head, left[0]) {
                if left.len() > 2 {
                    return process_chunks(left[1], &left[2..]);
                } else {
                    return &left[1..]
                }
            } else {
                return process_chunks(head, &left[0..]);
            }
        }
    }

    return &tail[1..];
}

fn is_opening(a: char) -> bool {
    return a == '{';
}

fn is_closing(a: char, b: char) -> bool {
    println!("Checking: {} and {}", a, b);
    match a {
        '{' => { return b == '}'; },
        _ => { return false; }
    }
}
