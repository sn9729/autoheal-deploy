module.exports = function(req, res, next) {
  // If session has no userId, user is not authenticated
  if (!req.session.userId) {
    return res.redirect('/login');
  }
  // Otherwise proceed
  next();
};
