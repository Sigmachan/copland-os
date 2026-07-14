use std::process::exit;
use upm::run;

#[tokio::main]
async fn main() {
    let args = std::env::args().skip(1).collect::<Vec<_>>();
    let ret = run(&args).await;
    exit(ret);
}
