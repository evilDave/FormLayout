# FormLayout

* Programmatic (no storyboard / nib)
* Autolayout
* UIScrollView
* Not hidden by keyboard
* Scroll to editing control
* Handles rotation

Why *is* this so hard. You know why? Because they chose to re-use the constraint system for working out how the scroll area works. You just need more constraints than you think - constrain UIScrollView to something, constrain its content view (the first subview) to the edges of the scrollview (these are the ones where they re-use the constaint system for something else), ensure that the content view gets a size from somewhere (constrain to its children, something else, whatever). See https://developer.apple.com/library/ios/technotes/tn2154/_index.html
