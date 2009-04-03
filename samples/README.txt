This folder contains some sample rWebUnit test suites.

To Run those tests, You need install 
  Ruby (1.8.6 or 1.9.x) and required libraries (called gems) 
     * rwebunit
     * watir
or 
  pre-packaged PRoR (http://www.itest2.com/downloads/) for Windows users.
  

Run from command line
    > spec -fs <test_filename>  
    (usually test file named as *_spec.rb, *_test.rb)

  Examples:
    > cd samples\HelloTestWorld
    > spec -fs assertion_spec.rb
  
    > cd samples\NewTours
    > spec -fs newtours_spec.rb
 
Run in iTest2 IDE
    Open project file (eg. samples/NewTours/newtours.tpr), click Run button. 
   
    Note:  iTest2 (http://www.itest2.com), which can make your developing rWebUnit/Watir tests easier.
 
Files

  HelloTestWorld
  --------------
   
  Contains dozens of simple test cases, the assertion_spec.rb shows how to do assertion in rWebUnit.
  
  NewTours
  --------

  NewTour is QuickTest Professional (QTP)'s sample web site.

  newtours_test.rb includes same test cases (using a QTP tutorial example) in two versions
   * recorded directly by iTest2 Recorder
   * refactored version using Page-Object-Design

  MyOrganizedInfo
  ----------------

  MyOrganized.Info is a Web 2.0 web site.
