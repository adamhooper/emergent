/** @jsx React.DOM */

var React = require('react');

module.exports = React.createClass({
  render: function() {
    return (

      /* JSX for about page */
      <div className="container">
        <h1>About Emergent</h1>
        <p>Emergent is a real-time rumor tracker. It's part of a research project with the Tow Center for Digital Journalism that focuses on how unverified information and rumor is reported in the media, and best practices for debunking misinformation. Read more about it <a href="http://www.craigsilverman.ca/2014/09/02/researching-rumors-and-debunking-for-the-tow-center-at-columbia-university/">here</a>.</p>
        <p>You can view a list of rumors being tracked on the hompeage, along with their current claim state (True, False, Unverified). Click on a story to visit a page that visualizes the sources reporting the rumor, and a breakdown of social shares per source.</p>
        <p>Have a rumor we should be tracking? A source we should add to an existing story? Feedback to share? <a href="mailto:craig@craigsilverman.ca">Email us</a>.</p>
        <p>You can also <a href="http://eepurl.com/3mb9T">sign up to our mailing list</a> for occasional updates.(We never sell or share your info.)</p>
        <p>Founder/Editor: Craig Silverman | Lead Developer: Adam Hooper | Design and Interaction: <a href="http://www.normative.com">Normative</a> | Research Assistant: Joscelyn Shawn Ganjhara Jurich</p>
      </div>

    );
  }
});
