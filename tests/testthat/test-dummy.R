testthat::test_that("dummy test", {
  testthat::expect_equal(1 + 1, 2)
})

testthat::test_that("rnaturalearthhires test", {
  testthat::expect_true(length(rnaturalearthhires::coastline10) > 0)
})