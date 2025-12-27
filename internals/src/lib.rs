use quote::quote;
use syn::{ItemFn, parse_macro_input, parse_quote};

#[proc_macro_attribute]
pub fn main(
    _args: proc_macro::TokenStream,
    item: proc_macro::TokenStream,
) -> proc_macro::TokenStream {
    let item = parse_macro_input!(item);

    if cfg!(debug_assertions) {
        wrap(item)
    } else {
        with_attrs(item)
    }
    .into()
}

fn with_attrs(item: ItemFn) -> proc_macro2::TokenStream {
    quote! {
        #[argio::argio(input = proconio::input)]
        #[proconio::fastout]
        #item
    }
}

fn wrap(mut item: ItemFn) -> proc_macro2::TokenStream {
    let name = &mut item.sig.ident;
    if name.eq(&"main") {
        *name = parse_quote!(__main);
    }

    let item = with_attrs(item);

    quote! {
        fn main() {
            if std::env::args().any(|a| a.starts_with("target/debug")) {
                use std::os::unix::process::CommandExt;
                let err = std::process::Command::new("mise")
                    .arg("test")
                    .arg(std::env!("CARGO_BIN_NAME"))
                    .exec();
                println!("{err:#?}");
            } else {
               __main();
            }
        }

        #item
    }
}
