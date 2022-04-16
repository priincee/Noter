const cookieParser = require("cookie-parser");
const csrf = require("csurf");
const bodyParser = require("body-parser");
const express = require("express");
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");
const path = require('path');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const csrfMiddleware = csrf({ cookie: true });

const PORT = process.env.PORT || 8080;
const app = express();
let currentUser = ""

app.engine("html", require("ejs").renderFile);
app.use('/static', express.static(path.join(__dirname, 'static')))


app.use(bodyParser.json());
app.use(cookieParser());
app.use(csrfMiddleware);

app.all("*", (req, res, next) => {
  res.cookie("XSRF-TOKEN", req.csrfToken());
  next();
});

app.get("/login", function (req, res) {
  res.render("login.html");
});

app.get("/signup", function (req, res) {
  res.render("signup.html");
});

app.get("/appview", function (req, res) {
  const sessionCookie = req.cookies.session || "";
  admin
   .auth()
   .verifySessionCookie(sessionCookie, true /** checkRevoked */)
   .then((userData) => {
     console.log("Logged in:", userData.email)
     res.render("appview.html");
   })
   .catch((error) => {
     res.redirect("/login");
   });
});

app.get("/", function (req, res) {
  res.render("index.html");
});

app.get("/getCurrentUserId", function (req, res) {
  const sessionCookie = req.cookies.session || "";
  admin
   .auth()
   .verifySessionCookie(sessionCookie, true /** checkRevoked */)
   .then((userData) => {
       res.json({uid: userData.uid})

   })
   .catch((error) => {
     res.redirect("/login");
   });

});

app.post("/sessionLogin", (req, res) => {
  const idToken = req.body.tokenId.toString();
  currentUser =  req.body.uid

  const expiresIn = 60 * 60 * 24 * 5 * 1000;

  admin
    .auth()
    .createSessionCookie(idToken, { expiresIn })
    .then(
      (sessionCookie) => {
        const options = { maxAge: expiresIn, httpOnly: true };
        res.cookie("session", sessionCookie, options);
        res.end(JSON.stringify({ status: "success" }));
      },
      (error) => {
        res.status(401).send("UNAUTHORIZED REQUEST!");
      }
    );
});

app.get("/sessionLogout", (req, res) => {
  res.clearCookie("session");
  currentUser = ""
  res.redirect("/login");
});

app.listen(PORT, "0.0.0.0", () => {
  console.log(`Listening on http://localhost:${PORT}`)
})
