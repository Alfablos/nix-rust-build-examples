use tokio::{
    sync::mpsc,
    time::{self, Duration}
};


#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {

    let (hello_tx, mut hello_rx) = mpsc::unbounded_channel::<&str>();
    let (goodbye_tx, mut goodbye_rx) = mpsc::unbounded_channel::<&str>();


    tokio::spawn(async move {
        loop {
            time::sleep(Duration::from_secs(1)).await;
            hello_tx.send("Hello world!").unwrap();
        }
    });

    tokio::spawn(async move {
        loop {
            time::sleep(Duration::from_secs(1)).await;
            goodbye_tx.send("Goodbye world!").unwrap();
        }
    });

    loop {
        
        tokio::select! {
            Some(hello) = hello_rx.recv() => println!("{hello}"),
            Some(goodbye) = goodbye_rx.recv() => println!("{goodbye}"),
        }
    }

    
}
