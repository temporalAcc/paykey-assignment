# PayKey's Developer Home Assignment

## Product Sales Viewer
In this task you would design and implement an application to help the company sales people who are traveling all the time. The sales guys and gals need a list of every product the company trades with and the sales of those products which is made with different currencies.

### Instructions:

* Fork the project
* Clone the forked project to your machine
* Read the implementation guidelines section
* Implement :)
* Push your implementation and let us know.

### Implementation guidelines

Your application should be constructed from two screens:

A. The main screen of the app should
  * Let the user select a specific product from a variety of products
  * Show the count of transactions for that product
  
B. When the user selects a product a second screen should show the following
  * Each transaction related to the selected product
  * The amount of each product converted to **GBP**
  * The list should be constructed of sections, each section will hold the title of the origianl currency (i.e USD, AUD, GBP etc) and group all those transactions together.
  
To Simplify the task, we attach two pairs of JSON files at the DataSets folder.

Please note:
  * You should develop a working solution with the simplest possible user interface
  * Some conversions may not be specified in the rates json. In case they are needed, they should be calculated using the known conversions
  * Two paris (a pair is Transaction and Rate file) should work for you solution to test different scenarios, and should be easily configurable from the code.
  * Other sets of data will be used to validate your solution, which should be general enough to handle all the possible scenarios, including empty data files and other common errors.
  * The solution should reflect your understanding of reusable, maintainable and testable code. (Bonus points if make some tests)
  * The solution should be architectured in a way that it's easy to change the source of data (i.e local storage, local file, server etc.)
  
  
Good Luck!
  
