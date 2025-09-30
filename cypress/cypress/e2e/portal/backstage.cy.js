describe("backstage", () => {
  it("tests backstage", () => {
    cy.visit("https://backstage.127-0-0-1.nip.io/");
    cy.contains('Explore').click();
    //cy.get("div.jss4-2505 > div:nth-of-type(2) span.MuiButton-label-2578").click();
  });
});
