describe("backstage", () => {
  it("tests backstage", () => {
    cy.visit("https://backstage.demo.kubrix.cloud/");
    cy.contains('Explore').click();
    //cy.get("div.jss4-2505 > div:nth-of-type(2) span.MuiButton-label-2578").click();
  });
});