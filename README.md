# MysticPizza on Broadway

Welcome to Mystic Pizza!

## Getting Started

To run the demo, first clone this repository:

    git clone https://github.com/mcrumm/mystic_pizza_on_broadway
    cd mystic_pizza_on_broadway

install dependencies:

    mix deps.get

and setup the database:

    mix ecto.setup

Then you can run the demo:

    mix run --no-halt

> Note: You will occasionally see errors in the output.  We're generating fake data, after all, and the Order IDs occasionally overlap.
