/** @jsx React.DOM */

var React = require('react');

module.exports = React.createClass({
  render: function() {
    return (
      /* JSX for about page */
      <div className="page-content page-about">
        <div className="container">
          <h1 className="page-title">About Emergent</h1>
          <p>
            Emergent is a real-time rumor tracker. It's part of a research project with
            the <a href="http://towcenter.org/">Tow Center for Digital Journalism</a> at
            Columbia University that focuses on how unverified information and rumor are
            reported in the media. It aims to develop best practices for debunking
            misinformation. Read more about the
            research <a href="http://www.craigsilverman.ca/2014/09/02/researching-rumors-and-debunking-for-the-tow-center-at-columbia-university/">here</a>.
          </p>
          <p>
            Have a rumor we should be tracking? A source we should add to an existing story?
            Feedback to share? <a href="mailto:craig@craigsilverman.ca">Email us</a>.
          </p>
          <p>
            You should also <a href="http://eepurl.com/3mb9T">sign up to our mailing list</a> for
            occasional updates. (We never sell or share your info.)
          </p>
          <h2>How to Use Emergent</h2>
          <p>
            You can view a list of rumors being tracked on the homepage, along with their
            current claim state (True, False, Unverified). Click on a story to visit a page
            that visualizes the sources reporting the rumor, and a breakdown of social shares
            per source. You can also click on individual articles on the story page to see specific
            revision and social share data about that article. For more detail about how Emergent works, <a href="http://emergentinfo.tumblr.com/">check out the posts on our blog</a>.
          </p>

          <h2>Credits</h2>
          <ul className="credits">
            <li><strong>Founder/Editor</strong>: <a href="http://www.craigsilverman.ca">Craig Silverman</a></li>
            <li><strong>Lead Developer</strong>: <a href="http://adamhooper.com">Adam Hooper</a></li>
            <li><strong>Design and Interaction</strong>: <a href="http://www.normative.com">Normative</a></li>
            <li><strong>Research Assistant</strong>: Joscelyn Jurich</li>
          </ul>
        </div>
      </div>
    );
  }
});
