======Tests Should Not Be Optional=====

{{https://cdn-images-1.medium.com/max/2000/1*0mGkhw1_uLkzLbps07mQ3Q.jpeg}}

I am of the opinion that any code that does not have accompanying automated tests should be considered inherently defective. When we write code we have certain notions of suitableness in mind. Tests are a way to express those notions in a way that others can run, and examine, independent of having to delve into our actual implementation. Tests provide a way to communicate about the code we write in regards to what it does, not simply how it does some thing. While those two notions of “what code does,” and “how code does something” seem almost like the same thing, I believe there is value in distinguishing them, and that distinction is why I think code without tests should be considered inherently defective.

=====What versus How=====

When we write code we are being prescriptive, we are stating with as much precision as our chosen language allows, or implies, the steps we want the computer to take in completing some work. Our implementation is a judgement about the best way, at a given point in time to accomplish something. This judgement has assumptions baked in that are derived from the context within which the code was written. When we commit to a particular implementation we are making the assertion that the code we are writing ought to work. But, the code we write makes only the most minimal of guarantees, and those guarantees it does make strongly are highly contextual.

However, when we write tests we are stepping out of the prescriptive and, hopefully, engaging with something more descriptive. This is a hopeful outlook because writing tests can simply reinforce the prescriptions inherent to the implementation and, in many cases, those represent poor tests. When I write tests I want to describe the behavior of my software, not how it accomplishes that behavior. The difference is subtle, but important. As an example let us take this snippet of implementation code a starting point:

<code ruby>
class Task < ActiveRecord::Base
  has_many :task_actions
  has_many :feed_items
  
  def reset
    update started_at: DateTime.now, completed_at: nil, failed_at: nil
    task_actions.destroy_all
    feed_items.each &:reset_completed
  end
end
</code>

There are a few ways this code could be tested, but I only want to compare two approaches. This first example, I would assert, is a poor test because of its reliance on internal implementation details:

<code ruby>
describe Task do
  describe "#reset" do
    subject { build :task, started_at: past_timestamp, completed_at: past_timestamp, failed_at: past_timestamp }
    let(:past_timestamp) { 3.weeks.ago }

    it "resets the started_at timestamp to now" do
      expect { subject.reset }.to change { subject.started_at }.from(past_timestamp).to(DateTime.now)
    end

    it "clears the completed_at timestamp" do
      expect { subject.reset }.to change { subject.completed_at }.from(past_timestamp).to(nil)
    end

    it "clears the failed_at timestamp" do
      expect { subject.reset }.to change { subject.failed_at }.from(past_timestamp).to(nil)
    end

    it "destroys all associated TaskActions" do
      expect(subject).to receive_message_chain(:task_actions, :destroy_all)
      subject.reset
    end

    it "calls #reset_completed on all associated FeedItems" do
      double = Object.new
      expect(subject).to receive(:feed_items).and_return([double])
      expect(double).to receive(:reset_completed)
      subject.reset
    end
  end
end
</code>

This set of tests, while providing complete coverage, is inextricably tied to how this method accomplishes its work. If at any point the specific internals of this method changes, then the tests will also need to change. In contrast, the following example tests are much better, in my opinion:

<code ruby>
describe Task do
  describe "#reset" do
    subject { build :task, started_at: past_timestamp, completed_at: past_timestamp, failed_at: past_timestamp }
    let(:past_timestamp) { 3.weeks.ago }

    it "resets the started_at timestamp to now" do
      expect { subject.reset }.to change { subject.started_at }.from(past_timestamp).to(DateTime.now)
    end

    it "clears the completed_at timestamp" do
      expect { subject.reset }.to change { subject.completed_at }.from(past_timestamp).to(nil)
    end

    it "clears the failed_at timestamp" do
      expect { subject.reset }.to change { subject.failed_at }.from(past_timestamp).to(nil)
    end

    it "destroys all associated TaskActions" do
      expect { subject.reset }.to change { subject.task_actions.count }.from(2).to(0)
    end

    it "resets completion state for all associated FeedItems" do
      expect { subject.reset }.to change { FeedItems.for(subject).completed.count }.from(3).to(0)
    end
  end
end
</code>

These tests, specifically the last two, focus on the behavior that this method encapsulates and could even be refactored away from this model should a service object, or some other pattern be desired with most of the changes being isolated to the context of the tests, not the tests themselves. By focussing on behavior, the internal implementation can change more substantially without needing the test code to change. Only when the overall behavior of the code changes will the test case need to change significantly. This emphasis on describing what the code does, versus how it does it, is where the value of tests come from. If tests only reinforce what is already prescribed in the implementation, then they are just another layer of coupling and fragility that will need to be contended with in the future. The emphasis of good, descriptive tests should be on the effects that some code causes. Tests should answer the question, what does this code cause to change, not how does this code accomplish that change.

====Prescription Alone is a Defect====

To return to my original assertion that code without accompanying tests should be considered inherently defective: without some aspect of description around a piece of software that can be run repeatedly and automatically, certainty about the behavior of the system, at any layer, will always be rooted in assumptions. While manual QA can provide a level of certainty that the software behaves as expected, that level of certainty relies entirely on how certain we are on the infallibility of humans.

Test code is full of assumptions as well, but those assumptions are part of the code and thus subject to inspection, adjustment, or removal. Tests allow for the controlling of what assumptions are in place at any given point in time in a way that manual QA does not facilitate well. Good manual QA requires meticulous documentation to achieve repeatability, and its scale is always limited by staffing. But, if manual QA discoveries can be codified with automated tests then the entire process can be made more efficient, reliable, and repeatable.

So, while automated tests can not replace all forms of manual QA, they can increase the reliability of the testing process and often can increase speed as well. But, the descriptiveness of manual QA and system-level testing is only one facet of the issue. Lower level tests, such as unit and other functional tests, as illustrated above, also reap benefits from automated testing. While it can be possible to test an entire system through only its public interface, testing the units that compose that system can often be far faster, and can lead to a much faster feedback cycle during development. That speed in both execution time and feedback is what allows lower level tests to help drive design decisions, guide refactoring, and prevent some bugs from making it to production in the first place.

If the only certainty that we have about a piece of software comes from the prescriptions of its implementation, then our certainty is incredibly shaky. The prescriptions are founded on assumptions that are at best implicit, and suitability for any present or future purpose is also entirely assumed. The compounding nature of the assumptions tied in to only working with software in its prescriptive form is not a feature, it is a serious defect, and the remedy is not terribly difficult or costly.

====Even a Little Description Instills Confidence====

I have walked into a few untested, or poorly tested code bases, and my initial impulse has become incredibly consistent: I try to figure out how to add tests. If a system is running then it meets some level of suitability, but sometimes it is tentative. In such code bases I prefer to write as high a level tests as possible. This trades off test runtime speed for coverage and anti-fragility. Higher level integration or acceptance tests always run slower, and cover more than unit tests. But, they also tend to be easier to write in a way that captures effects rather than methods. For this reason they can help us more rapidly build confidence around a system.

The trick with adding this kind of descriptive clarity and confidence to a system is knowing where to begin. This is best answered by non-technical stakeholders. Ask them to identify what the system does that is either the most valuable to the business, or would represent the greatest risk if it were incorrect. Then ask them to define its expected behavior at the present time. Then write the tests around that system to match the description provided.

This approach will often surface bugs in the existing implementation. Whenever this happens make note of them and encapsulate the proof in pending test cases, but focus on capture what the system currently does. Once the existing effects of the system are captured then bring your finding regarding buggy behavior to stakeholders and discuss their relative importance to establish when, or if, they need to be addressed. The good this is you will have some level of testing around those issues which will allow you to know when you have fixed them, if that time comes.

====Putting Code Coverage in its Place====

Repeatedly I’ve referred to code coverage. I value code coverage a lot. On all the projects I actively maintain I aim for 100% C0 coverage. There are two reasons for this: confidence and testability. Having 100% code coverage does not guarantee my code is defect free, or even correct; but it does mean I have tests that exercise every line of my code in some way. This means all my code can run. It also means that all my code is testable by way of being reachable via tests.

But, code coverage is not the goal. Poorly written tests can also achieve high levels of coverage, so test coverage proves very little. But, it can be a helpful metric when rightly understood. I highly recommend Martin Fowler’s [[https://martinfowler.com/bliki/TestCoverage.html|brief commentary on the topic]] for getting a healthy perspective.

=====Confidence & Clarity=====

The goal with writing tests around code is to provide confidence that the desired behaviors, the effects of the system, are in place. That is the first goal of testing. The second goal is to communicate that desired behavior to other in a way that is clear. Good code is clear code, and the same goes for tests. Tests are another form of code, and so they ought to be clear too. But, it is important to remember the different types of clarity involved: your implementation code should clearly communicate how your software does something, while the test code should clearly communicate what your software does. In this way tests provide another helpful angle for understanding a software system and why it has value.
