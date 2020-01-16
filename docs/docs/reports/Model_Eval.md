---
layout: default
title: Model Eval
parent: Reports
---

<a href="https://mybinder.org/v2/gh/machine-learning-apps/mlops-dashboard/master">
  <button class="btn btn-primary mr-2" type="button">Run Notebook</button>
</a>

# Evaluate Model

Compute a confusion matrix

    Normalized confusion matrix
    [[0.88173203 0.09765211 0.02061586]
     [0.1303451  0.83997974 0.02967516]
     [0.27873486 0.23896011 0.48230502]]





    <matplotlib.axes._subplots.AxesSubplot at 0x7f487d90af60>




![png](Model_Eval_files/Model_Eval_2_2.png)


# Make Predictions

    Using TensorFlow backend.



```python
issue_labeler.get_probabilities(body='Can someone please help me?', 
                                title='random stuff')
```




    {'bug': 0.12618249654769897,
     'feature': 0.1929263472557068,
     'question': 0.6808911561965942}




```python
issue_labeler.get_probabilities(body='It would be great to add a new button', 
                                title='requesting a button')
```




    {'bug': 0.019261939451098442,
     'feature': 0.9305700659751892,
     'question': 0.05016808584332466}




```python
issue_labeler.get_probabilities(body='It does` not work, I get bad errors', 
                                title='nothing works')
```




    {'bug': 0.9065071940422058,
     'feature': 0.03202613815665245,
     'question': 0.06146678701043129}


