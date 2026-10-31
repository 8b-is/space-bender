use std::env;
use std::path::PathBuf;
use std::process::Command;

fn main() {
    println!("cargo:rerun-if-changed=solution_arm64.s");
    println!("cargo:rerun-if-changed=solution.asm");

    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());
    let obj = out_dir.join("solution_arm64.o");
    let lib = out_dir.join("libdance_asm.a");

    let status = Command::new("clang")
        .args(["-c", "solution_arm64.s", "-o"])
        .arg(&obj)
        .status()
        .expect("failed to invoke clang on solution_arm64.s");
    assert!(status.success(), "clang failed on solution_arm64.s");

    let status = Command::new("ar")
        .args(["crs"])
        .arg(&lib)
        .arg(&obj)
        .status()
        .expect("failed to invoke ar");
    assert!(status.success(), "ar failed");

    println!("cargo:rustc-link-search=native={}", out_dir.display());
    println!("cargo:rustc-link-lib=static=dance_asm");
}
