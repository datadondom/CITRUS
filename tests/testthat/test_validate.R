library(citrus)
library(testthat)
library(dplyr)

transactional_data <- citrus::transactional_data
data <- transactional_data %>% select(c('transactionid', 'transactionvalue', 'customerid', 'orderdate'))
output_preprocess <- citrus::preprocess(data, numeric_operation_list = 'mean')
preprocess_too_many_categories <- citrus::preprocessed_data %>%
  mutate(faulty_feature = as.character(customerid))
preprocess_no_customerid <- citrus::preprocessed_data %>%
  select(-customerid)

hyperparameters_tree = list(dependent_variable = 'response',
                            min_segmentation_fraction = 0.05,
                            number_of_personas = 6,
                            print_plot = FALSE,
                            print_safety_check=20)

test_that("Supervised without response variable", {
  expect_error(citrus::validate(output_preprocess, force = TRUE, hyperparameters = hyperparameters_tree), regexp = "Columns missing: response")
})

test_that("Correct error when customerid is missing.", {
  expect_error(citrus::validate(preprocess_no_customerid, force = TRUE, hyperparameters = hyperparameters_tree), regexp = "Columns missing: customerid")
})

test_that("Throw error when too many categorical levels", {
  expect_error(citrus::validate(preprocess_too_many_categories, force = FALSE, hyperparameters = hyperparameters_tree), regexp = "Categorical Columns have too many levels: faulty_feature")
})

test_that("Unique customer count", {
  expect_equal(nrow(output_preprocess), length(unique(output_preprocess[["customerid"]])))
})
