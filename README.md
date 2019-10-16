# MystexPizza on Broadway

Welcome to Mystex Pizza!

## Getting Started

To run the demo, first clone this repository:

    git clone https://github.com/mcrumm/mystex_pizza_on_broadway
    cd mystex_pizza_on_broadway

install dependencies:

    mix deps.get

and setup the database:

    mix ecto.setup

Then you can run the demo:

    mix run --no-halt

> Note: You will occasionally see errors in the output.  We're generating fake data, after all, and the Order IDs occasionally overlap.

Check the number of customers created:

    mix pizza.customers

Check the number of orders created:

    mix pizza.orders

Finally, you can clean up your database:

    mix ecto.drop
