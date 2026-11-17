mod api;
mod node;

#[tokio::main]
async fn main() -> n0_error::Result<()> {
    tracing_subscriber::fmt::init();
    node::peer().await?;
    Ok(())
}

