/*
* Copyright (c) 2015 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import Foundation
import WatchKit
import BitWatchKit

class InterfaceController: WKInterfaceController {

  @IBOutlet weak var priceLabel: WKInterfaceLabel!
  @IBOutlet weak var image: WKInterfaceImage!
  @IBOutlet weak var lastUpdatedLabel: WKInterfaceLabel!

  let tracker = Tracker()
  var updating = false

  override func awakeWithContext(context: AnyObject?) {
    super.awakeWithContext(context)

    // Configure interface objects here.
    updatePrice(tracker.cachedPrice())
    image.setHidden(true)
    updateDate(tracker.cachedDate())
  }

  override func willActivate() {
    // This method is called when watch view controller is about to be visible to user
    super.willActivate()

    update()
  }

  override func didDeactivate() {
    // This method is called when watch view controller is no longer visible
    super.didDeactivate()
  }

  @IBAction func refreshTapped() {
    update()
  }

  private func updatePrice(price: NSNumber) {
    priceLabel.setText(Tracker.priceFormatter.stringFromNumber(price))
  }

  private func update() {
    // 1
    if !updating {
      updating = true
      // 2
      let originalPrice = tracker.cachedPrice()
      // 3
      tracker.requestPrice { (price, error) -> () in
        // 4
        if error == nil {
          self.updatePrice(price!)
          self.updateDate(NSDate())
          self.updateImage(originalPrice, newPrice: price!)
        }
        self.updating = false
      }
    }
  }

  private func updateDate(date: NSDate) {
    self.lastUpdatedLabel.setText("Last updated \(Tracker.dateFormatter.stringFromDate(date))")
  }

  private func updateImage(originalPrice: NSNumber, newPrice: NSNumber) {
    if originalPrice.isEqualToNumber(newPrice) {
      // 1
      image.setHidden(true)
    } else {
      // 2
      if newPrice.doubleValue > originalPrice.doubleValue {
        image.setImageNamed("Up")
      } else {
        image.setImageNamed("Down")
      }
      image.setHidden(false)
    }
  }
}
