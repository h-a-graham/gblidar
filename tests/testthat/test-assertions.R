test_that("assert_aoi works", {
  scafell_box <- sf::st_point(c(321633, 507181)) |>
    sf::st_buffer(2000) |>
    sf::st_sfc() |>
    sf::st_set_crs(27700)

  expect_equal(
    as.vector(sf::st_bbox(assert_aoi(scafell_box))),
    c(319633, 505181, 323633, 509181)
  )
})
