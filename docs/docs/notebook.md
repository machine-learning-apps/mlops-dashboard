---
layout: default
title: Interactive-Notebook-Altair
nav_order: 7
---

  <script src="https://cdn.jsdelivr.net/npm/vega@3"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega@5"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-lite@2"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-lite@3"></script>
  <script src="https://cdn.jsdelivr.net/npm/vega-embed@3"></script>
  

<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h1 id="Interaction">Interaction<a class="anchor-link" href="#Interaction">&#182;</a></h1><p><em>“A graphic is not ‘drawn’ once and for all; it is ‘constructed’ and reconstructed until it reveals all the relationships constituted by the interplay of the data. The best graphic operations are those carried out by the decision-maker themself.”</em> &mdash; <a href="https://books.google.com/books?id=csqX_xnm4tcC">Jacques Bertin</a></p>
<p>Visualization provides a powerful means of making sense of data. A single image, however, typically provides answers to, at best, a handful of questions. Through <em>interaction</em> we can transform static images into tools for exploration: highlighting points of interest, zooming in to reveal finer-grained patterns, and linking across multiple views to reason about multi-dimensional relationships.</p>
<p>At the core of interaction is the notion of a <em>selection</em>: a means of indicating to the computer which elements or regions we are interested in. For example, we might hover the mouse over a point, click multiple marks, or draw a bounding box around a region to highlight subsets of the data for further scrutiny.</p>
<p>Alongside visual encodings and data transformations, Altair provides a <em>selection</em> abstraction for authoring interactions. These selections encompass three aspects:</p>
<ol>
<li>Input event handling to select points or regions of interest, such as mouse hover, click, drag, scroll, and touch events.</li>
<li>Generalizing from the input to form a selection rule (or <a href="https://en.wikipedia.org/wiki/Predicate_%28mathematical_logic%29"><em>predicate</em></a>) that determines whether or not a given data record lies within the selection.</li>
<li>Using the selection predicate to dynamically configure a visualization by driving <em>conditional encodings</em>, <em>filter transforms</em>, or <em>scale domains</em>.</li>
</ol>
<p>This notebook introduces interactive selections and explores how to use them to author a variety of interaction techniques, such as dynamic queries, panning &amp; zooming, details-on-demand, and brushing &amp; linking.</p>
<p><em>This notebook is part of the <a href="https://github.com/uwdata/visualization-curriculum">data visualization curriculum</a>.</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[1]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="kn">import</span> <span class="nn">pandas</span> <span class="k">as</span> <span class="nn">pd</span>
<span class="kn">import</span> <span class="nn">altair</span> <span class="k">as</span> <span class="nn">alt</span>
</pre></div>

    </div>
</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Datasets">Datasets<a class="anchor-link" href="#Datasets">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>We will visualize a variety of datasets from the <a href="https://github.com/vega/vega-datasets">vega-datasets</a> collection:</p>
<ul>
<li>A dataset of <code>cars</code> from the 1970s and early 1980s,</li>
<li>A dataset of <code>movies</code>, previously used in the <a href="https://github.com/uwdata/visualization-curriculum/blob/master/altair_data_transformation.ipynb">Data Transformation</a> notebook,</li>
<li>A dataset containing ten years of <a href="https://en.wikipedia.org/wiki/S%26P_500_Index">S&amp;P 500</a> (<code>sp500</code>) stock prices,</li>
<li>A dataset of technology company <code>stocks</code>, and</li>
<li>A dataset of <code>flights</code>, including departure time, distance, and arrival delay.</li>
</ul>

</div>
</div>
</div>te
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[2]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">cars</span> <span class="o">=</span> <span class="s1">&#39;https://vega.github.io/vega-datasets/data/cars.json&#39;</span>
<span class="n">movies</span> <span class="o">=</span> <span class="s1">&#39;https://vega.github.io/vega-datasets/data/movies.json&#39;</span>
<span class="n">sp500</span> <span class="o">=</span> <span class="s1">&#39;https://vega.github.io/vega-datasets/data/sp500.csv&#39;</span>
<span class="n">stocks</span> <span class="o">=</span> <span class="s1">&#39;https://vega.github.io/vega-datasets/data/stocks.csv&#39;</span>
<span class="n">flights</span> <span class="o">=</span> <span class="s1">&#39;https://vega.github.io/vega-datasets/data/flights-5k.json&#39;</span>
</pre></div>

    </div>
</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Introducing-Selections">Introducing Selections<a class="anchor-link" href="#Introducing-Selections">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's start with a basic selection: simply clicking a point to highlight it. Using the <code>cars</code> dataset, we'll start with a scatter plot of horsepower versus miles per gallon, with a color encoding for the number cylinders in the car engine.</p>
<p>In addition, we'll create a selection instance by calling <code>alt.selection_single()</code>, indicating we want a selection defined over a <em>single value</em>. By default, the selection uses a mouse click to determine the selected value. To register a selection with a chart, we must add it using the <code>.add_selection()</code> method.</p>
<p>Once our selection has been defined, we can use it as a parameter for <em>conditional encodings</em>, which apply a different encoding depending on whether a data record lies in or out of the selection. For example, consider the following code:</p>
<div class="highlight"><pre><span></span><span class="n">color</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selection</span><span class="p">,</span> <span class="s1">&#39;Cylinders:O&#39;</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="s1">&#39;grey&#39;</span><span class="p">))</span>
</pre></div>
<p><strong>Hamel: <code>alt.condition</code> means conditional encodings</strong></p>
<p>This encoding definition states that data points contained within the <code>selection</code> should be colored according to the <code>Cylinder</code> field, while non-selected data points should use a default <code>grey</code>. An empty selection includes <em>all</em> data points, and so initially all points will be colored.</p>
<p><em>Try clicking different points in the chart below. What happens? (Click the background to clear the selection state and return to an "empty" selection.)</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[3]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">selection</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">();</span>
  
<span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">cars</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">selection</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Horsepower:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="s1">&#39;Miles_per_Gallon:Q&#39;</span><span class="p">,</span>
    <span class="n">color</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selection</span><span class="p">,</span> <span class="s1">&#39;Cylinders:O&#39;</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="s1">&#39;grey&#39;</span><span class="p">)),</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selection</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.8</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.1</span><span class="p">))</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[3]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-1"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-1");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "data": {"url": "https://vega.github.io/vega-datasets/data/cars.json"}, "mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector001"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector001"}, "value": 0.1}, "x": {"type": "quantitative", "field": "Horsepower"}, "y": {"type": "quantitative", "field": "Miles_per_Gallon"}}, "selection": {"selector001": {"type": "single"}}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Of course, highlighting individual data points one-at-a-time is not particularly exciting! As we'll see, however, single value selections provide a useful building block for more powerful interactions. Moreover, single value selections are just one of the three selection types provided by Altair:</p>
<ul>
<li><code>selection_single</code> - select a single discrete value, by default on click events. </li>
<li><code>selection_multi</code> - select multiple discrete values. The first value is selected on mouse click and additional values toggled using shift-click. </li>
<li><code>selection_interval</code> - select a continuous range of values, initiated by mouse drag.</li>
</ul>
<p>Let's compare each of these selection types side-by-side. To keep our code tidy we'll first define a function (<code>plot</code>) that generates a scatter plot specification just like the one above. We can pass a selection to the <code>plot</code> function to have it applied to the chart:</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[4]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="k">def</span> <span class="nf">plot</span><span class="p">(</span><span class="n">selection</span><span class="p">):</span>
    <span class="k">return</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">cars</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
        <span class="n">selection</span>
    <span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
        <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Horsepower:Q&#39;</span><span class="p">,</span>
        <span class="n">y</span><span class="o">=</span><span class="s1">&#39;Miles_per_Gallon:Q&#39;</span><span class="p">,</span>
        <span class="n">color</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selection</span><span class="p">,</span> <span class="s1">&#39;Cylinders:O&#39;</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="s1">&#39;grey&#39;</span><span class="p">)),</span>
        <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selection</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.8</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.1</span><span class="p">))</span>
    <span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
        <span class="n">width</span><span class="o">=</span><span class="mi">240</span><span class="p">,</span>
        <span class="n">height</span><span class="o">=</span><span class="mi">180</span>
    <span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Let's use our <code>plot</code> function to create three chart variants, one per selection type.</p>
<p>The first (<code>single</code>) chart replicates our earlier example. The second (<code>multi</code>) chart supports shift-click interactions to toggle inclusion of multiple points within the selection. The third (<code>interval</code>) chart generates a selection region (or <em>brush</em>) upon mouse drag. Once created, you can drag the brush around to select different points, or scroll when the cursor is inside the brush to scale (zoom) the brush size.</p>
<p><em>Try interacting with each of the charts below!</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[5]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">alt</span><span class="o">.</span><span class="n">hconcat</span><span class="p">(</span>
  <span class="n">plot</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">())</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">title</span><span class="o">=</span><span class="s1">&#39;Single (Click)&#39;</span><span class="p">),</span>
  <span class="n">plot</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">selection_multi</span><span class="p">())</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">title</span><span class="o">=</span><span class="s1">&#39;Multi (Shift-Click)&#39;</span><span class="p">),</span>
  <span class="n">plot</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">())</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">title</span><span class="o">=</span><span class="s1">&#39;Interval (Drag)&#39;</span><span class="p">)</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[5]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-2"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-2");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "hconcat": [{"mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector002"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector002"}, "value": 0.1}, "x": {"type": "quantitative", "field": "Horsepower"}, "y": {"type": "quantitative", "field": "Miles_per_Gallon"}}, "height": 180, "selection": {"selector002": {"type": "single"}}, "title": "Single (Click)", "width": 240}, {"mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector003"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector003"}, "value": 0.1}, "x": {"type": "quantitative", "field": "Horsepower"}, "y": {"type": "quantitative", "field": "Miles_per_Gallon"}}, "height": 180, "selection": {"selector003": {"type": "multi"}}, "title": "Multi (Shift-Click)", "width": 240}, {"mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector004"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector004"}, "value": 0.1}, "x": {"type": "quantitative", "field": "Horsepower"}, "y": {"type": "quantitative", "field": "Miles_per_Gallon"}}, "height": 180, "selection": {"selector004": {"type": "interval"}}, "title": "Interval (Drag)", "width": 240}], "data": {"url": "https://vega.github.io/vega-datasets/data/cars.json"}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The examples above use default interactions (click, shift-click, drag) for each selection type. We can further customize the interactions by providing input event specifications using <a href="https://vega.github.io/vega/docs/event-streams/">Vega event selector syntax</a>. For example, we can modify our <code>single</code> and <code>multi</code> charts to trigger upon <code>mouseover</code> events instead of <code>click</code> events.</p>
<p><em>Hold down the shift key in the second chart to "paint" with data!</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[6]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">alt</span><span class="o">.</span><span class="n">hconcat</span><span class="p">(</span>
  <span class="n">plot</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">(</span><span class="n">on</span><span class="o">=</span><span class="s1">&#39;mouseover&#39;</span><span class="p">))</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">title</span><span class="o">=</span><span class="s1">&#39;Single (Mouseover)&#39;</span><span class="p">),</span>
  <span class="n">plot</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">selection_multi</span><span class="p">(</span><span class="n">on</span><span class="o">=</span><span class="s1">&#39;mouseover&#39;</span><span class="p">))</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">title</span><span class="o">=</span><span class="s1">&#39;Multi (Shift-Mouseover)&#39;</span><span class="p">)</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[6]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-3"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-3");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "hconcat": [{"mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector005"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector005"}, "value": 0.1}, "x": {"type": "quantitative", "field": "Horsepower"}, "y": {"type": "quantitative", "field": "Miles_per_Gallon"}}, "height": 180, "selection": {"selector005": {"type": "single", "on": "mouseover"}}, "title": "Single (Mouseover)", "width": 240}, {"mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector006"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector006"}, "value": 0.1}, "x": {"type": "quantitative", "field": "Horsepower"}, "y": {"type": "quantitative", "field": "Miles_per_Gallon"}}, "height": 180, "selection": {"selector006": {"type": "multi", "on": "mouseover"}}, "title": "Multi (Shift-Mouseover)", "width": 240}], "data": {"url": "https://vega.github.io/vega-datasets/data/cars.json"}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now that we've covered the basics of Altair selections, let's take a tour through the various interaction techniques they enable!</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Dynamic-Queries">Dynamic Queries<a class="anchor-link" href="#Dynamic-Queries">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><em>Dynamic queries</em> enables rapid, reversible exploration of data to isolate patterns of interest. As defined by <a href="https://www.cs.umd.edu/~ben/papers/Ahlberg1992Dynamic.pdf">Ahlberg, Williamson, &amp; Shneiderman</a>, a dynamic query:</p>
<ul>
<li>represents a query graphically,</li>
<li>provides visible limits on the query range,</li>
<li>provides a graphical representation of the data and query result,</li>
<li>gives immediate feedback of the result after every query adjustment,</li>
<li>and allows novice users to begin working with little training.</li>
</ul>
<p>A common approach is to manipulate query parameters using standard user interface widgets such as sliders, radio buttons, and drop-down menus. To generate dynamic query widgets, we can apply a selection's <code>bind</code> operation to one or more data fields we wish to query.</p>
<p>Let's build an interactive scatter plot that uses a dynamic query to filter the display. Given a scatter plot of movie ratings (from Rotten Tomates and IMDB), we can add a selection over the <code>Major_Genre</code> field to enable interactive filtering by film genre.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>To start, let's extract the unique (non-null) genres from the <code>movies</code> data:</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[7]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">df</span> <span class="o">=</span> <span class="n">pd</span><span class="o">.</span><span class="n">read_json</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span> <span class="c1"># load movies data</span>
<span class="n">genres</span> <span class="o">=</span> <span class="n">df</span><span class="p">[</span><span class="s1">&#39;Major_Genre&#39;</span><span class="p">]</span><span class="o">.</span><span class="n">unique</span><span class="p">()</span> <span class="c1"># get unique field values</span>
<span class="n">genres</span> <span class="o">=</span> <span class="nb">list</span><span class="p">(</span><span class="nb">filter</span><span class="p">(</span><span class="k">lambda</span> <span class="n">d</span><span class="p">:</span> <span class="n">d</span> <span class="ow">is</span> <span class="ow">not</span> <span class="kc">None</span><span class="p">,</span> <span class="n">genres</span><span class="p">))</span> <span class="c1"># filter out None values</span>
<span class="n">genres</span><span class="o">.</span><span class="n">sort</span><span class="p">()</span> <span class="c1"># sort alphabetically</span>
</pre></div>

    </div>
</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>For later use, let's also define a list of unique <code>MPAA_Rating</code> values:</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[8]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">mpaa</span> <span class="o">=</span> <span class="p">[</span><span class="s1">&#39;G&#39;</span><span class="p">,</span> <span class="s1">&#39;PG&#39;</span><span class="p">,</span> <span class="s1">&#39;PG-13&#39;</span><span class="p">,</span> <span class="s1">&#39;R&#39;</span><span class="p">,</span> <span class="s1">&#39;NC-17&#39;</span><span class="p">,</span> <span class="s1">&#39;Not Rated&#39;</span><span class="p">]</span>
</pre></div>

    </div>
</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Now let's create a <code>single</code> selection bound to a drop-down menu.</p>
<p><em>Use the dynamic query menu below to explore the data. How do ratings vary by genre? How would you revise the code to filter <code>MPAA_Rating</code> (G, PG, PG-13, etc.) instead of <code>Major_Genre</code>?</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[11]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">selectGenre</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">(</span>
    <span class="n">name</span><span class="o">=</span><span class="s1">&#39;Select&#39;</span><span class="p">,</span> <span class="c1"># name the selection &#39;Select&#39;</span>
    <span class="n">fields</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Major_Genre&#39;</span><span class="p">],</span> <span class="c1"># limit selection to the Major_Genre field</span>
    <span class="n">init</span><span class="o">=</span><span class="p">{</span><span class="s1">&#39;Major_Genre&#39;</span><span class="p">:</span> <span class="n">genres</span><span class="p">[</span><span class="mi">0</span><span class="p">]},</span> <span class="c1"># use first genre entry as initial value</span>
    <span class="c1"># BINDING_SELECT is what creates the WIDGET!!</span>
    <span class="n">bind</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">binding_select</span><span class="p">(</span><span class="n">options</span><span class="o">=</span><span class="n">genres</span><span class="p">)</span> <span class="c1"># bind to a menu of unique genre values</span>
<span class="p">)</span>

<span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">selectGenre</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selectGenre</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.75</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.05</span><span class="p">))</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[11]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-5"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-5");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "mark": "circle", "encoding": {"opacity": {"condition": {"value": 0.75, "selection": "Select"}, "value": 0.05}, "tooltip": {"type": "nominal", "field": "Title"}, "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "selection": {"Select": {"type": "single", "fields": ["Major_Genre"], "init": {"Major_Genre": "Action"}, "bind": {"input": "select", "options": ["Action", "Adventure", "Black Comedy", "Comedy", "Concert/Performance", "Documentary", "Drama", "Horror", "Musical", "Romantic Comedy", "Thriller/Suspense", "Western"]}}}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Our construction above leverages multiple aspects of selections:</p>
<ul>
<li>We give the selection a name (<code>'Select'</code>). This name is not required, but allows us to influence the label text of the generated dynamic query menu. (<em>What happens if you remove the name? Try it!</em>)</li>
<li>We constrain the selection to a specific data field (<code>Major_Genre</code>). Earlier when we used a <code>single</code> selection, the selection mapped to individual data points. By limiting the selection to a specific field, we can select <em>all</em> data points whose <code>Major_Genre</code> field value matches the single selected value.</li>
<li>We initialize <code>init=...</code> the selection to a starting value.</li>
<li>We <code>bind</code> the selection to an interface widget, in this case a drop-down menu via <code>binding_select</code>.</li>
<li>As before, we then use a conditional encoding to control the opacity channel.</li>
</ul>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h3 id="Binding-Selections-to-Multiple-Inputs">Binding Selections to Multiple Inputs<a class="anchor-link" href="#Binding-Selections-to-Multiple-Inputs">&#182;</a></h3><p>One selection instance can be bound to <em>multiple</em> dynamic query widgets. Let's modify the example above to provide filters for <em>both</em> <code>Major_Genre</code> and <code>MPAA_Rating</code>, using radio buttons instead of a menu. Our <code>single</code> selection is now defined over a single <em>pair</em> of genre and MPAA rating values</p>
<p><em>Look for surprising conjunctions of genre and rating. Are there any G or PG-rated horror films?</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[12]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="c1"># single-value selection over [Major_Genre, MPAA_Rating] pairs</span>
<span class="c1"># use specific hard-wired values as the initial selected values</span>
<span class="n">selection</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">(</span>
    <span class="n">name</span><span class="o">=</span><span class="s1">&#39;Select&#39;</span><span class="p">,</span>
    <span class="n">fields</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Major_Genre&#39;</span><span class="p">,</span> <span class="s1">&#39;MPAA_Rating&#39;</span><span class="p">],</span>
    <span class="n">init</span><span class="o">=</span><span class="p">{</span><span class="s1">&#39;Major_Genre&#39;</span><span class="p">:</span> <span class="s1">&#39;Drama&#39;</span><span class="p">,</span> <span class="s1">&#39;MPAA_Rating&#39;</span><span class="p">:</span> <span class="s1">&#39;R&#39;</span><span class="p">},</span>
    <span class="n">bind</span><span class="o">=</span><span class="p">{</span><span class="s1">&#39;Major_Genre&#39;</span><span class="p">:</span> <span class="n">alt</span><span class="o">.</span><span class="n">binding_select</span><span class="p">(</span><span class="n">options</span><span class="o">=</span><span class="n">genres</span><span class="p">),</span> <span class="s1">&#39;MPAA_Rating&#39;</span><span class="p">:</span> <span class="n">alt</span><span class="o">.</span><span class="n">binding_radio</span><span class="p">(</span><span class="n">options</span><span class="o">=</span><span class="n">mpaa</span><span class="p">)}</span>
<span class="p">)</span>
  
<span class="c1"># scatter plot, modify opacity based on selection</span>
<span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">selection</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">selection</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.75</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.05</span><span class="p">))</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[12]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-6"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-6");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "mark": "circle", "encoding": {"opacity": {"condition": {"value": 0.75, "selection": "Select"}, "value": 0.05}, "tooltip": {"type": "nominal", "field": "Title"}, "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "selection": {"Select": {"type": "single", "fields": ["Major_Genre", "MPAA_Rating"], "init": {"Major_Genre": "Drama", "MPAA_Rating": "R"}, "bind": {"Major_Genre": {"input": "select", "options": ["Action", "Adventure", "Black Comedy", "Comedy", "Concert/Performance", "Documentary", "Drama", "Horror", "Musical", "Romantic Comedy", "Thriller/Suspense", "Western"]}, "MPAA_Rating": {"input": "radio", "options": ["G", "PG", "PG-13", "R", "NC-17", "Not Rated"]}}}}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><em>Fun facts: The PG-13 rating didn't exist when the movies <a href="https://www.imdb.com/title/tt0073195/">Jaws</a> and <a href="https://www.imdb.com/title/tt0077766/">Jaws 2</a> were released. The first film to receive a PG-13 rating was 1984's <a href="https://www.imdb.com/title/tt0087985/">Red Dawn</a>.</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h3 id="Using-Visualizations-as-Dynamic-Queries">Using Visualizations as Dynamic Queries<a class="anchor-link" href="#Using-Visualizations-as-Dynamic-Queries">&#182;</a></h3><p>Though standard interface widgets show the <em>possible</em> query parameter values, they do not visualize the <em>distribution</em> of those values. We might also wish to use richer interactions, such as multi-value or interval selections, rather than input widgets that select only a single value at a time.</p>
<p>To address these issues, we can author additional charts to both visualize data and support dynamic queries. Let's add a histogram of the count of films per year and use an interval selection to dynamically highlight films over selected time periods.</p>
<p><em>Interact with the year histogram to explore films from different time periods. Do you seen any evidence of <a href="https://en.wikipedia.org/wiki/Sampling_bias">sampling bias</a> across the years? (How do year and critics' ratings relate?)</em></p>
<p><em>The years range from 1930 to 2040! Are future films in pre-production, or are there "off-by-one century" errors? Also, depending on which time zone you're in, you may see a small bump in either 1969 or 1970. Why might that be? (See the end of the notebook for an explanation!)</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[20]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">brush</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">(</span>
    <span class="n">encodings</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;x&#39;</span><span class="p">]</span> <span class="c1"># limit selection to x-axis (year) values</span>
<span class="p">)</span>

<span class="c1"># dynamic query histogram</span>
<span class="n">years</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_bar</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">brush</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="s1">&#39;year(Release_Date):T&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="s1">&#39;Films by Release Year&#39;</span><span class="p">),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;count():Q&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="kc">None</span><span class="p">),</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">brush</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.75</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.05</span><span class="p">))</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">650</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">50</span>
<span class="p">)</span>

<span class="c1"># scatter plot, modify opacity based on selection</span>
<span class="n">ratings</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">brush</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.75</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.05</span><span class="p">))</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">650</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">400</span>
<span class="p">)</span>

<span class="n">alt</span><span class="o">.</span><span class="n">vconcat</span><span class="p">(</span><span class="n">years</span><span class="p">,</span> <span class="n">ratings</span><span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">spacing</span><span class="o">=</span><span class="mi">5</span><span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[20]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-13"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-13");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "vconcat": [{"mark": "bar", "encoding": {"opacity": {"condition": {"value": 0.75, "selection": "selector014"}, "value": 0.05}, "x": {"type": "temporal", "field": "Release_Date", "timeUnit": "year", "title": "Films by Release Year"}, "y": {"type": "quantitative", "aggregate": "count", "title": null}}, "height": 50, "selection": {"selector014": {"type": "interval", "encodings": ["x"]}}, "width": 650}, {"mark": "circle", "encoding": {"opacity": {"condition": {"value": 0.75, "selection": "selector014"}, "value": 0.05}, "tooltip": {"type": "nominal", "field": "Title"}, "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "height": 400, "width": 650}], "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "spacing": 5, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[21]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">brush</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_multi</span><span class="p">(</span>
    <span class="n">on</span><span class="o">=</span><span class="s1">&#39;mouseover&#39;</span><span class="p">,</span>
    <span class="n">encodings</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;x&#39;</span><span class="p">]</span> <span class="c1"># limit selection to x-axis (year) values</span>
<span class="p">)</span>

<span class="c1"># dynamic query histogram</span>
<span class="n">years</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_bar</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">brush</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="s1">&#39;year(Release_Date):T&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="s1">&#39;Films by Release Year&#39;</span><span class="p">),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;count():Q&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="kc">None</span><span class="p">),</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">brush</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.75</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.05</span><span class="p">))</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">650</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">50</span>
<span class="p">)</span>

<span class="c1"># scatter plot, modify opacity based on selection</span>
<span class="n">ratings</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">brush</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.75</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.05</span><span class="p">))</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">650</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">400</span>
<span class="p">)</span>

<span class="n">alt</span><span class="o">.</span><span class="n">vconcat</span><span class="p">(</span><span class="n">years</span><span class="p">,</span> <span class="n">ratings</span><span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">spacing</span><span class="o">=</span><span class="mi">5</span><span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[21]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-14"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-14");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "vconcat": [{"mark": "bar", "encoding": {"opacity": {"condition": {"value": 0.75, "selection": "selector015"}, "value": 0.05}, "x": {"type": "temporal", "field": "Release_Date", "timeUnit": "year", "title": "Films by Release Year"}, "y": {"type": "quantitative", "aggregate": "count", "title": null}}, "height": 50, "selection": {"selector015": {"type": "multi", "on": "mouseover", "encodings": ["x"]}}, "width": 650}, {"mark": "circle", "encoding": {"opacity": {"condition": {"value": 0.75, "selection": "selector015"}, "value": 0.05}, "tooltip": {"type": "nominal", "field": "Title"}, "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "height": 400, "width": 650}], "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "spacing": 5, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The example above provides dynamic queries using a <em>linked selection</em> between charts:</p>
<ul>
<li>We create an <code>interval</code> selection (<code>brush</code>), and set <code>encodings=['x']</code> to limit the selection to the x-axis only, resulting in a one-dimensional selection interval.</li>
<li>We register <code>brush</code> with our histogram of films per year via <code>.add_selection(brush)</code>.</li>
<li>We use <code>brush</code> in a conditional encoding to adjust the scatter plot <code>opacity</code>.</li>
</ul>
<p>This interaction technique of selecting elements in one chart and seeing linked highlights in one or more other charts is known as <a href="https://en.wikipedia.org/wiki/Brushing_and_linking"><em>brushing &amp; linking</em></a>.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Panning-&amp;-Zooming">Panning &amp; Zooming<a class="anchor-link" href="#Panning-&amp;-Zooming">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The movie rating scatter plot is a bit cluttered in places, making it hard to examine points in denser regions. Using the interaction techniques of <em>panning</em> and <em>zooming</em>, we can inspect dense regions more closely.</p>
<p>Let's start by thinking about how we might express panning and zooming using Altair selections. What defines the "viewport" of a chart? <em>Axis scale domains!</em></p>
<p>We can change the scale domains to modify the visualized range of data values. To do so interactively, we can bind an <code>interval</code> selection to scale domains with the code <code>bind='scales'</code>. The result is that instead of an interval brush that we can drag and zoom, we instead can drag and zoom the entire plotting area!</p>
<p><em>In the chart below, click and drag to pan (translate) the view, or scroll to zoom (scale) the view. What can you discover about the precision of the provided rating values?</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[27]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">(</span><span class="n">bind</span><span class="o">=</span><span class="s1">&#39;scales&#39;</span><span class="p">)</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span> <span class="n">axis</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Axis</span><span class="p">(</span><span class="n">minExtent</span><span class="o">=</span><span class="mi">30</span><span class="p">)),</span> <span class="c1"># use min extent to stabilize axis title placement</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span> <span class="s1">&#39;Release_Date:N&#39;</span><span class="p">,</span> <span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span> <span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">]</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">600</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">400</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[27]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-20"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-20");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "mark": "circle", "encoding": {"tooltip": [{"type": "nominal", "field": "Title"}, {"type": "nominal", "field": "Release_Date"}, {"type": "quantitative", "field": "IMDB_Rating"}, {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}], "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "axis": {"minExtent": 30}, "field": "IMDB_Rating"}}, "height": 400, "selection": {"selector021": {"type": "interval", "bind": "scales"}}, "width": 600, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><em>Zooming in, we can see that the rating values have limited precision! The Rotten Tomatoes ratings are integers, while the IMDB ratings are truncated to tenths. As a result, there is overplotting even when we zoom, with multiple movies sharing the same rating values.</em></p>
<p>Reading the code above, you may notice the code <code>alt.Axis(minExtent=30)</code> in the <code>y</code> encoding channel. The <code>minExtent</code> parameter ensures a minimum amount of space is reserved for axis ticks and labels. Why do this? When we pan and zoom, the axis labels may change and cause the axis title position to shift. By setting a minimum extent we can reduce distracting movements in the plot. <em>Try changing the <code>minExtent</code> value, for example setting it to zero, and then zoom out to see what happens when longer axis labels enter the view.</em></p>
<p>Altair also includes a shorthand for adding panning and zooming to a plot. Instead of directly creating a selection, you can call <code>.interactive()</code> to have Altair automatically generate an interval selection bound to the chart's scales:</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[28]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span> <span class="n">axis</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Axis</span><span class="p">(</span><span class="n">minExtent</span><span class="o">=</span><span class="mi">30</span><span class="p">)),</span> <span class="c1"># use min extent to stabilize axis title placement</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span> <span class="s1">&#39;Release_Date:N&#39;</span><span class="p">,</span> <span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span> <span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">]</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">600</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">400</span>
<span class="p">)</span><span class="o">.</span><span class="n">interactive</span><span class="p">()</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[28]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-21"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-21");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "mark": "circle", "encoding": {"tooltip": [{"type": "nominal", "field": "Title"}, {"type": "nominal", "field": "Release_Date"}, {"type": "quantitative", "field": "IMDB_Rating"}, {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}], "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "axis": {"minExtent": 30}, "field": "IMDB_Rating"}}, "height": 400, "selection": {"selector022": {"type": "interval", "bind": "scales", "encodings": ["x", "y"]}}, "width": 600, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>By default, scale bindings for selections include both the <code>x</code> and <code>y</code> encoding channels. What if we want to limit panning and zooming along a single dimension? We can invoke <code>encodings=['x']</code> to constrain the selection to the <code>x</code> channel only:</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[29]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">movies</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">(</span><span class="n">bind</span><span class="o">=</span><span class="s1">&#39;scales&#39;</span><span class="p">,</span> <span class="n">encodings</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;x&#39;</span><span class="p">])</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span> <span class="n">axis</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Axis</span><span class="p">(</span><span class="n">minExtent</span><span class="o">=</span><span class="mi">30</span><span class="p">)),</span> <span class="c1"># use min extent to stabilize axis title placement</span>
    <span class="n">tooltip</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Title:N&#39;</span><span class="p">,</span> <span class="s1">&#39;Release_Date:N&#39;</span><span class="p">,</span> <span class="s1">&#39;IMDB_Rating:Q&#39;</span><span class="p">,</span> <span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">]</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">600</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">400</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[29]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-22"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-22");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "mark": "circle", "encoding": {"tooltip": [{"type": "nominal", "field": "Title"}, {"type": "nominal", "field": "Release_Date"}, {"type": "quantitative", "field": "IMDB_Rating"}, {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}], "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "axis": {"minExtent": 30}, "field": "IMDB_Rating"}}, "height": 400, "selection": {"selector023": {"type": "interval", "bind": "scales", "encodings": ["x"]}}, "width": 600, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><em>When zooming along a single axis only, the shape of the visualized data can change, potentially affecting our perception of relationships in the data. <a href="http://vis.stanford.edu/papers/arclength-banking">Choosing an appropriate aspect ratio</a> is an important visualization design concern!</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Navigation:-Overview-+-Detail">Navigation: Overview + Detail<a class="anchor-link" href="#Navigation:-Overview-+-Detail">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>When panning and zooming, we directly adjust the "viewport" of a chart. The related navigation strategy of <em>overview + detail</em> instead uses an overview display to show <em>all</em> of the data, while supporting selections that pan and zoom a separate focus display.</p>
<p>Below we have two area charts showing a decade of price fluctuations for the S&amp;P 500 stock index. Initially both charts show the same data range. <em>Click and drag in the bottom overview chart to update the focus display and examine specific time spans.</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[30]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">brush</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">(</span><span class="n">encodings</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;x&#39;</span><span class="p">]);</span>

<span class="n">base</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">()</span><span class="o">.</span><span class="n">mark_area</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="s1">&#39;date:T&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="kc">None</span><span class="p">),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;price:Q&#39;</span><span class="p">)</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">700</span>
<span class="p">)</span>
  
<span class="n">alt</span><span class="o">.</span><span class="n">vconcat</span><span class="p">(</span>
    <span class="n">base</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="s1">&#39;date:T&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="kc">None</span><span class="p">,</span> <span class="n">scale</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Scale</span><span class="p">(</span><span class="n">domain</span><span class="o">=</span><span class="n">brush</span><span class="p">))),</span>
    <span class="n">base</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span><span class="n">brush</span><span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span><span class="n">height</span><span class="o">=</span><span class="mi">60</span><span class="p">),</span>
    <span class="n">data</span><span class="o">=</span><span class="n">sp500</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[30]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-23"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-23");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "vconcat": [{"mark": "area", "encoding": {"x": {"type": "temporal", "field": "date", "scale": {"domain": {"selection": "selector024"}}, "title": null}, "y": {"type": "quantitative", "field": "price"}}, "width": 700}, {"mark": "area", "encoding": {"x": {"type": "temporal", "field": "date", "title": null}, "y": {"type": "quantitative", "field": "price"}}, "height": 60, "selection": {"selector024": {"type": "interval", "encodings": ["x"]}}, "width": 700}], "data": {"url": "https://vega.github.io/vega-datasets/data/sp500.csv"}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Unlike our earlier panning &amp; zooming case, here we don't want to bind a selection directly to the scales of a single interactive chart. Instead, we want to bind the selection to a scale domain in <em>another</em> chart. To do so, we update the <code>x</code> encoding channel for our focus chart, setting the scale <code>domain</code> property to reference our <code>brush</code> selection. If no interval is defined (the selection is empty), Altair ignores the brush and uses the underlying data to determine the domain. When a brush interval is created, Altair instead uses that as the scale <code>domain</code> for the focus chart.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Details-on-Demand">Details on Demand<a class="anchor-link" href="#Details-on-Demand">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Once we spot points of interest within a visualization, we often want to know more about them. <em>Details-on-demand</em> refers to interactively querying for more information about selected values. <em>Tooltips</em> are one useful means of providing details on demand. However, tooltips typically only show information for one data point at a time. How might we show more?</p>
<p>The movie ratings scatterplot includes a number of potentially interesting outliers where the Rotten Tomatoes and IMDB ratings disagree. Let's create a plot that allows us to interactively select points and show their labels.</p>
<p><em>Mouse over points in the scatter plot below to see a highlight and title label. Shift-click points to make annotations persistent and view multiple labels at once. Which movies are loved by Rotten Tomatoes critics, but not the general audience on IMDB (or vice versa)? See if you can find possible errors, where two different movies with the same name were accidentally combined!</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[31]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">hover</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">(</span>
    <span class="n">on</span><span class="o">=</span><span class="s1">&#39;mouseover&#39;</span><span class="p">,</span>  <span class="c1"># select on mouseover</span>
    <span class="n">nearest</span><span class="o">=</span><span class="kc">True</span><span class="p">,</span>    <span class="c1"># select nearest point to mouse cursor</span>
    <span class="n">empty</span><span class="o">=</span><span class="s1">&#39;none&#39;</span>     <span class="c1"># empty selection should match nothing</span>
<span class="p">)</span>

<span class="n">click</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_multi</span><span class="p">(</span>
    <span class="n">empty</span><span class="o">=</span><span class="s1">&#39;none&#39;</span> <span class="c1"># empty selection matches no points</span>
<span class="p">)</span>

<span class="c1"># scatter plot encodings shared by all marks</span>
<span class="n">plot</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">()</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">x</span><span class="o">=</span><span class="s1">&#39;Rotten_Tomatoes_Rating:Q&#39;</span><span class="p">,</span>
    <span class="n">y</span><span class="o">=</span><span class="s1">&#39;IMDB_Rating:Q&#39;</span>
<span class="p">)</span>
  
<span class="c1"># shared base for new layers</span>
<span class="n">base</span> <span class="o">=</span> <span class="n">plot</span><span class="o">.</span><span class="n">transform_filter</span><span class="p">(</span>
    <span class="c1"># logical OR is supported by Vega-Lite, nice syntax still needed for Altair</span>
    <span class="p">{</span><span class="s1">&#39;or&#39;</span><span class="p">:</span> <span class="p">[</span><span class="n">hover</span><span class="p">,</span> <span class="n">click</span><span class="p">]}</span> <span class="c1"># filter to points in either selection</span>
<span class="p">)</span>

<span class="c1"># layer scatter plot points, halo annotations, and title labels</span>
<span class="n">alt</span><span class="o">.</span><span class="n">layer</span><span class="p">(</span>
    <span class="n">plot</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span><span class="n">hover</span><span class="p">)</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span><span class="n">click</span><span class="p">),</span>
    <span class="n">base</span><span class="o">.</span><span class="n">mark_point</span><span class="p">(</span><span class="n">size</span><span class="o">=</span><span class="mi">100</span><span class="p">,</span> <span class="n">stroke</span><span class="o">=</span><span class="s1">&#39;firebrick&#39;</span><span class="p">,</span> <span class="n">strokeWidth</span><span class="o">=</span><span class="mi">1</span><span class="p">),</span>
    <span class="n">base</span><span class="o">.</span><span class="n">mark_text</span><span class="p">(</span><span class="n">dx</span><span class="o">=</span><span class="mi">4</span><span class="p">,</span> <span class="n">dy</span><span class="o">=-</span><span class="mi">8</span><span class="p">,</span> <span class="n">align</span><span class="o">=</span><span class="s1">&#39;right&#39;</span><span class="p">,</span> <span class="n">stroke</span><span class="o">=</span><span class="s1">&#39;white&#39;</span><span class="p">,</span> <span class="n">strokeWidth</span><span class="o">=</span><span class="mi">2</span><span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span><span class="n">text</span><span class="o">=</span><span class="s1">&#39;Title:N&#39;</span><span class="p">),</span>
    <span class="n">base</span><span class="o">.</span><span class="n">mark_text</span><span class="p">(</span><span class="n">dx</span><span class="o">=</span><span class="mi">4</span><span class="p">,</span> <span class="n">dy</span><span class="o">=-</span><span class="mi">8</span><span class="p">,</span> <span class="n">align</span><span class="o">=</span><span class="s1">&#39;right&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span><span class="n">text</span><span class="o">=</span><span class="s1">&#39;Title:N&#39;</span><span class="p">),</span>
    <span class="n">data</span><span class="o">=</span><span class="n">movies</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">600</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">450</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[31]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-24"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-24");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "layer": [{"mark": "circle", "encoding": {"x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "selection": {"selector025": {"type": "single", "on": "mouseover", "nearest": true, "empty": "none"}, "selector026": {"type": "multi", "empty": "none"}}}, {"mark": {"type": "point", "size": 100, "stroke": "firebrick", "strokeWidth": 1}, "encoding": {"x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "transform": [{"filter": {"or": [{"selection": "selector025"}, {"selection": "selector026"}]}}]}, {"mark": {"type": "text", "align": "right", "dx": 4, "dy": -8, "stroke": "white", "strokeWidth": 2}, "encoding": {"text": {"type": "nominal", "field": "Title"}, "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "transform": [{"filter": {"or": [{"selection": "selector025"}, {"selection": "selector026"}]}}]}, {"mark": {"type": "text", "align": "right", "dx": 4, "dy": -8}, "encoding": {"text": {"type": "nominal", "field": "Title"}, "x": {"type": "quantitative", "field": "Rotten_Tomatoes_Rating"}, "y": {"type": "quantitative", "field": "IMDB_Rating"}}, "transform": [{"filter": {"or": [{"selection": "selector025"}, {"selection": "selector026"}]}}]}], "data": {"url": "https://vega.github.io/vega-datasets/data/movies.json"}, "height": 450, "width": 600, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>The example above adds three new layers to the scatter plot: a circular annotation, white text to provide a legible background, and black text showing a film title. In addition, this example uses two selections in tandem:</p>
<ol>
<li>A single selection (<code>hover</code>) that includes <code>nearest=True</code> to automatically select the nearest data point as the mouse moves.</li>
<li>A multi selection (<code>click</code>) to create persistent selections via shift-click.</li>
</ol>
<p>Both selections include the set <code>empty='none'</code> to indicate that no points should be included if a selection is empty. These selections are then combined into a single filter predicate &mdash; the logical <em>or</em> of <code>hover</code> and <code>click</code> &mdash; to include points that reside in <em>either</em> selection. We use this predicate to filter the new layers to show annotations and labels for selected points only.</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Using selections and layers, we can realize a number of different designs for details on demand! For example, here is a log-scaled time series of technology stock prices, annotated with a guideline and labels for the date nearest the mouse cursor:</p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[41]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="c1"># select a point for which to provide details-on-demand</span>
<span class="n">label</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_single</span><span class="p">(</span>
    <span class="n">encodings</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;x&#39;</span><span class="p">],</span> <span class="c1"># limit selection to x-axis value</span>
    <span class="n">on</span><span class="o">=</span><span class="s1">&#39;mouseover&#39;</span><span class="p">,</span>  <span class="c1"># select on mouseover events</span>
    <span class="n">nearest</span><span class="o">=</span><span class="kc">True</span><span class="p">,</span>    <span class="c1"># select data point nearest the cursor</span>
    <span class="n">empty</span><span class="o">=</span><span class="s1">&#39;none&#39;</span>     <span class="c1"># empty selection includes no data points</span>
<span class="p">)</span>

<span class="c1"># define our base line chart of stock prices</span>
<span class="n">base</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">()</span><span class="o">.</span><span class="n">mark_line</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="s1">&#39;date:T&#39;</span><span class="p">),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;price:Q&#39;</span><span class="p">,</span> <span class="n">scale</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Scale</span><span class="p">(</span><span class="nb">type</span><span class="o">=</span><span class="s1">&#39;log&#39;</span><span class="p">)),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Color</span><span class="p">(</span><span class="s1">&#39;symbol:N&#39;</span><span class="p">)</span>
<span class="p">)</span>

<span class="n">alt</span><span class="o">.</span><span class="n">layer</span><span class="p">(</span>
    <span class="n">base</span><span class="p">,</span> <span class="c1"># base line chart</span>
    
    <span class="c1"># add a rule mark to serve as a guide line</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">()</span><span class="o">.</span><span class="n">mark_rule</span><span class="p">(</span><span class="n">color</span><span class="o">=</span><span class="s1">&#39;#aaa&#39;</span><span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
        <span class="n">x</span><span class="o">=</span><span class="s1">&#39;date:T&#39;</span>
    <span class="p">)</span><span class="o">.</span><span class="n">transform_filter</span><span class="p">(</span><span class="n">label</span><span class="p">),</span>
    
    <span class="c1"># add circle marks for selected time points, hide unselected points</span>
    <span class="n">base</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
        <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">label</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mi">1</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mi">0</span><span class="p">))</span>
    <span class="p">)</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span><span class="n">label</span><span class="p">),</span>

    <span class="c1"># add white stroked text to provide a legible background for labels</span>
    <span class="n">base</span><span class="o">.</span><span class="n">mark_text</span><span class="p">(</span><span class="n">align</span><span class="o">=</span><span class="s1">&#39;left&#39;</span><span class="p">,</span> <span class="n">dx</span><span class="o">=</span><span class="mi">5</span><span class="p">,</span> <span class="n">dy</span><span class="o">=-</span><span class="mi">5</span><span class="p">,</span> <span class="n">stroke</span><span class="o">=</span><span class="s1">&#39;white&#39;</span><span class="p">,</span> <span class="n">strokeWidth</span><span class="o">=</span><span class="mi">5</span><span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
        <span class="n">text</span><span class="o">=</span><span class="s1">&#39;price:Q&#39;</span>
    <span class="p">)</span><span class="o">.</span><span class="n">transform_filter</span><span class="p">(</span><span class="n">label</span><span class="p">),</span>

    <span class="c1"># add text labels for stock prices</span>
    <span class="n">base</span><span class="o">.</span><span class="n">mark_text</span><span class="p">(</span><span class="n">align</span><span class="o">=</span><span class="s1">&#39;left&#39;</span><span class="p">,</span> <span class="n">dx</span><span class="o">=</span><span class="mi">5</span><span class="p">,</span> <span class="n">dy</span><span class="o">=-</span><span class="mi">5</span><span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
        <span class="n">text</span><span class="o">=</span><span class="s1">&#39;price:Q&#39;</span>
    <span class="p">)</span><span class="o">.</span><span class="n">transform_filter</span><span class="p">(</span><span class="n">label</span><span class="p">),</span>
    
    <span class="n">data</span><span class="o">=</span><span class="n">stocks</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">700</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">400</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[41]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-34"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-34");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "layer": [{"mark": "line", "encoding": {"color": {"type": "nominal", "field": "symbol"}, "x": {"type": "temporal", "field": "date"}, "y": {"type": "quantitative", "field": "price", "scale": {"type": "log"}}}}, {"mark": {"type": "rule", "color": "#aaa"}, "encoding": {"x": {"type": "temporal", "field": "date"}}, "transform": [{"filter": {"selection": "selector036"}}]}, {"mark": "circle", "encoding": {"color": {"type": "nominal", "field": "symbol"}, "opacity": {"condition": {"value": 1, "selection": "selector036"}, "value": 0}, "x": {"type": "temporal", "field": "date"}, "y": {"type": "quantitative", "field": "price", "scale": {"type": "log"}}}, "selection": {"selector036": {"type": "single", "encodings": ["x"], "on": "mouseover", "nearest": true, "empty": "none"}}}, {"mark": {"type": "text", "align": "left", "dx": 5, "dy": -5, "stroke": "white", "strokeWidth": 5}, "encoding": {"color": {"type": "nominal", "field": "symbol"}, "text": {"type": "quantitative", "field": "price"}, "x": {"type": "temporal", "field": "date"}, "y": {"type": "quantitative", "field": "price", "scale": {"type": "log"}}}, "transform": [{"filter": {"selection": "selector036"}}]}, {"mark": {"type": "text", "align": "left", "dx": 5, "dy": -5}, "encoding": {"color": {"type": "nominal", "field": "symbol"}, "text": {"type": "quantitative", "field": "price"}, "x": {"type": "temporal", "field": "date"}, "y": {"type": "quantitative", "field": "price", "scale": {"type": "log"}}}, "transform": [{"filter": {"selection": "selector036"}}]}], "data": {"url": "https://vega.github.io/vega-datasets/data/stocks.csv"}, "height": 400, "width": 700, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><em>Putting into action what we've learned so far: can you modify the movie scatter plot above (the one with the dynamic query over years) to include a <code>rule</code> mark that shows the average IMDB (or Rotten Tomatoes) rating for the data contained within the year <code>interval</code> selection?</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Brushing-&amp;-Linking,-Revisited">Brushing &amp; Linking, Revisited<a class="anchor-link" href="#Brushing-&amp;-Linking,-Revisited">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Earlier in this notebook we saw an example of <em>brushing &amp; linking</em>: using a dynamic query histogram to highlight points in a movie rating scatter plot. Here, we'll visit some additional examples involving linked selections.</p>
<p>Returning to the <code>cars</code> dataset, we can use the <code>repeat</code> operator to build a <a href="https://en.wikipedia.org/wiki/Scatter_plot#Scatterplot_matrices">scatter plot matrix (SPLOM)</a> that shows associations between mileage, acceleration, and horsepower. We can define an <code>interval</code> selection and include it <em>within</em> our repeated scatter plot specification to enable linked selections among all the plots.</p>
<p><em>Click and drag in any of the plots below to perform brushing &amp; linking!</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[42]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">brush</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">(</span>
    <span class="n">resolve</span><span class="o">=</span><span class="s1">&#39;global&#39;</span> <span class="c1"># resolve all selections to a single global instance</span>
<span class="p">)</span>

<span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">(</span><span class="n">cars</span><span class="p">)</span><span class="o">.</span><span class="n">mark_circle</span><span class="p">()</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span>
    <span class="n">brush</span>
<span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">repeat</span><span class="p">(</span><span class="s1">&#39;column&#39;</span><span class="p">),</span> <span class="nb">type</span><span class="o">=</span><span class="s1">&#39;quantitative&#39;</span><span class="p">),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">repeat</span><span class="p">(</span><span class="s1">&#39;row&#39;</span><span class="p">),</span> <span class="nb">type</span><span class="o">=</span><span class="s1">&#39;quantitative&#39;</span><span class="p">),</span>
    <span class="n">color</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">brush</span><span class="p">,</span> <span class="s1">&#39;Cylinders:O&#39;</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="s1">&#39;grey&#39;</span><span class="p">)),</span>
    <span class="n">opacity</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">condition</span><span class="p">(</span><span class="n">brush</span><span class="p">,</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.8</span><span class="p">),</span> <span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="mf">0.1</span><span class="p">))</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">140</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">140</span>
<span class="p">)</span><span class="o">.</span><span class="n">repeat</span><span class="p">(</span>
    <span class="n">column</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Acceleration&#39;</span><span class="p">,</span> <span class="s1">&#39;Horsepower&#39;</span><span class="p">,</span> <span class="s1">&#39;Miles_per_Gallon&#39;</span><span class="p">],</span>
    <span class="n">row</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;Miles_per_Gallon&#39;</span><span class="p">,</span> <span class="s1">&#39;Horsepower&#39;</span><span class="p">,</span> <span class="s1">&#39;Acceleration&#39;</span><span class="p">]</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[42]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-35"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-35");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300}}, "repeat": {"column": ["Acceleration", "Horsepower", "Miles_per_Gallon"], "row": ["Miles_per_Gallon", "Horsepower", "Acceleration"]}, "spec": {"data": {"url": "https://vega.github.io/vega-datasets/data/cars.json"}, "mark": "circle", "encoding": {"color": {"condition": {"type": "ordinal", "field": "Cylinders", "selection": "selector037"}, "value": "grey"}, "opacity": {"condition": {"value": 0.8, "selection": "selector037"}, "value": 0.1}, "x": {"type": "quantitative", "field": {"repeat": "column"}}, "y": {"type": "quantitative", "field": {"repeat": "row"}}}, "height": 140, "selection": {"selector037": {"type": "interval", "resolve": "global"}}, "width": 140}, "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>Note above the use of <code>resolve='global'</code> on the <code>interval</code> selection. The default setting of <code>'global'</code> indicates that across all plots only one brush can be active at a time. However, in some cases we might want to define brushes in multiple plots and combine the results. If we use <code>resolve='union'</code>, the selection will be the <em>union</em> of all brushes: if a point resides within any brush it will be selected. Alternatively, if we use <code>resolve='intersect'</code>, the selection will consist of the <em>intersection</em> of all brushes: only points that reside within all brushes will be selected.</p>
<p><em>Try setting the <code>resolve</code> parameter to <code>'union'</code> and <code>'intersect'</code> and see how it changes the resulting selection logic.</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h3 id="Cross-Filtering">Cross-Filtering<a class="anchor-link" href="#Cross-Filtering">&#182;</a></h3><p>The brushing &amp; linking examples we've looked at all use conditional encodings, for example to change opacity values in response to a selection. Another option is to use a selection defined in one view to <em>filter</em> the content of another view.</p>
<p>Let's build a collection of histograms for the <code>flights</code> dataset: arrival <code>delay</code> (how early or late a flight arrives, in minutes), <code>distance</code> flown (in miles), and <code>time</code> of departure (hour of the day). We'll use the <code>repeat</code> operator to create the histograms, and add an <code>interval</code> selection for the <code>x</code> axis with brushes resolved via intersection.</p>
<p>In particular, each histogram will consist of two layers: a gray background layer and a blue foreground layer, with the foreground layer filtered by our intersection of brush selections. The result is a <em>cross-filtering</em> interaction across the three charts!</p>
<p><em>Drag out brush intervals in the charts below. As you select flights with longer or shorter arrival delays, how do the distance and time distributions respond?</em></p>

</div>
</div>
</div>
<div class="cell border-box-sizing code_cell rendered">
<div class="input">
<div class="prompt input_prompt">In&nbsp;[47]:</div>
<div class="inner_cell">
    <div class="input_area">
<div class=" highlight hl-ipython3"><pre><span></span><span class="n">brush</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">selection_interval</span><span class="p">(</span>
    <span class="n">encodings</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;x&#39;</span><span class="p">],</span>
    <span class="n">resolve</span><span class="o">=</span><span class="s1">&#39;intersect&#39;</span>
<span class="p">);</span>

<span class="n">hist</span> <span class="o">=</span> <span class="n">alt</span><span class="o">.</span><span class="n">Chart</span><span class="p">()</span><span class="o">.</span><span class="n">mark_bar</span><span class="p">()</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">X</span><span class="p">(</span><span class="n">alt</span><span class="o">.</span><span class="n">repeat</span><span class="p">(</span><span class="s1">&#39;row&#39;</span><span class="p">),</span> <span class="nb">type</span><span class="o">=</span><span class="s1">&#39;quantitative&#39;</span><span class="p">,</span>
        <span class="nb">bin</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Bin</span><span class="p">(</span><span class="n">maxbins</span><span class="o">=</span><span class="mi">100</span><span class="p">,</span> <span class="n">minstep</span><span class="o">=</span><span class="mi">1</span><span class="p">),</span> <span class="c1"># up to 100 bins</span>
        <span class="n">axis</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">Axis</span><span class="p">(</span><span class="nb">format</span><span class="o">=</span><span class="s1">&#39;d&#39;</span><span class="p">,</span> <span class="n">titleAnchor</span><span class="o">=</span><span class="s1">&#39;start&#39;</span><span class="p">)</span> <span class="c1"># integer format, left-aligned title</span>
    <span class="p">),</span>
    <span class="n">alt</span><span class="o">.</span><span class="n">Y</span><span class="p">(</span><span class="s1">&#39;count():Q&#39;</span><span class="p">,</span> <span class="n">title</span><span class="o">=</span><span class="kc">None</span><span class="p">)</span> <span class="c1"># no y-axis title</span>
<span class="p">)</span>
  
<span class="n">alt</span><span class="o">.</span><span class="n">layer</span><span class="p">(</span>
    <span class="n">hist</span><span class="o">.</span><span class="n">add_selection</span><span class="p">(</span><span class="n">brush</span><span class="p">)</span><span class="o">.</span><span class="n">encode</span><span class="p">(</span><span class="n">color</span><span class="o">=</span><span class="n">alt</span><span class="o">.</span><span class="n">value</span><span class="p">(</span><span class="s1">&#39;lightgrey&#39;</span><span class="p">)),</span>
    <span class="n">hist</span><span class="o">.</span><span class="n">transform_filter</span><span class="p">(</span><span class="n">brush</span><span class="p">)</span>
<span class="p">)</span><span class="o">.</span><span class="n">properties</span><span class="p">(</span>
    <span class="n">width</span><span class="o">=</span><span class="mi">900</span><span class="p">,</span>
    <span class="n">height</span><span class="o">=</span><span class="mi">100</span>
<span class="p">)</span><span class="o">.</span><span class="n">repeat</span><span class="p">(</span>
    <span class="n">row</span><span class="o">=</span><span class="p">[</span><span class="s1">&#39;delay&#39;</span><span class="p">,</span> <span class="s1">&#39;distance&#39;</span><span class="p">,</span> <span class="s1">&#39;time&#39;</span><span class="p">],</span>
    <span class="n">data</span><span class="o">=</span><span class="n">flights</span>
<span class="p">)</span><span class="o">.</span><span class="n">transform_calculate</span><span class="p">(</span>
    <span class="n">delay</span><span class="o">=</span><span class="s1">&#39;datum.delay &lt; 180 ? datum.delay : 180&#39;</span><span class="p">,</span> <span class="c1"># clamp delays &gt; 3 hours</span>
    <span class="n">time</span><span class="o">=</span><span class="s1">&#39;hours(datum.date) + minutes(datum.date) / 60&#39;</span> <span class="c1"># fractional hours</span>
<span class="p">)</span><span class="o">.</span><span class="n">configure_view</span><span class="p">(</span>
    <span class="n">stroke</span><span class="o">=</span><span class="s1">&#39;transparent&#39;</span> <span class="c1"># no outline</span>
<span class="p">)</span>
</pre></div>

    </div>
</div>
</div>

<div class="output_wrapper">
<div class="output">


<div class="output_area">

    <div class="prompt output_prompt">Out[47]:</div>



   
        
            
<div class="output_html rendered_html output_subarea output_execute_result">

<div id="altair-viz-40"></div>
<script type="text/javascript">
  (function(spec, embedOpt){
    const outputDiv = document.getElementById("altair-viz-40");
    const paths = {
      "vega": "https://cdn.jsdelivr.net/npm//vega@5?noext",
      "vega-lib": "https://cdn.jsdelivr.net/npm//vega-lib?noext",
      "vega-lite": "https://cdn.jsdelivr.net/npm//vega-lite@4.0.0?noext",
      "vega-embed": "https://cdn.jsdelivr.net/npm//vega-embed@6?noext",
    };

    function loadScript(lib) {
      return new Promise(function(resolve, reject) {
        var s = document.createElement('script');
        s.src = paths[lib];
        s.async = true;
        s.onload = () => resolve(paths[lib]);
        s.onerror = () => reject(`Error loading script: ${paths[lib]}`);
        document.getElementsByTagName("head")[0].appendChild(s);
      });
    }

    function showError(err) {
      outputDiv.innerHTML = `<div class="error" style="color:red;">${err}</div>`;
      throw err;
    }

    function displayChart(vegaEmbed) {
      vegaEmbed(outputDiv, spec, embedOpt)
        .catch(err => showError(`Javascript Error: ${err.message}<br>This usually means there's a typo in your chart specification. See the javascript console for the full traceback.`));
    }

    if(typeof define === "function" && define.amd) {
      requirejs.config({paths});
      require(["vega-embed"], displayChart, err => showError(`Error loading script: ${err.message}`));
    } else if (typeof vegaEmbed === "function") {
      displayChart(vegaEmbed);
    } else {
      loadScript("vega")
        .then(() => loadScript("vega-lite"))
        .then(() => loadScript("vega-embed"))
        .catch(showError)
        .then(() => displayChart(vegaEmbed));
    }
  })({"config": {"view": {"continuousWidth": 400, "continuousHeight": 300, "stroke": "transparent"}}, "repeat": {"row": ["delay", "distance", "time"]}, "spec": {"layer": [{"mark": "bar", "encoding": {"color": {"value": "lightgrey"}, "x": {"type": "quantitative", "axis": {"format": "d", "titleAnchor": "start"}, "bin": {"maxbins": 100, "minstep": 1}, "field": {"repeat": "row"}}, "y": {"type": "quantitative", "aggregate": "count", "title": null}}, "selection": {"selector042": {"type": "interval", "encodings": ["x"], "resolve": "intersect"}}}, {"mark": "bar", "encoding": {"x": {"type": "quantitative", "axis": {"format": "d", "titleAnchor": "start"}, "bin": {"maxbins": 100, "minstep": 1}, "field": {"repeat": "row"}}, "y": {"type": "quantitative", "aggregate": "count", "title": null}}, "transform": [{"filter": {"selection": "selector042"}}]}], "height": 100, "width": 900}, "data": {"url": "https://vega.github.io/vega-datasets/data/flights-5k.json"}, "transform": [{"calculate": "datum.delay < 180 ? datum.delay : 180", "as": "delay"}, {"calculate": "hours(datum.date) + minutes(datum.date) / 60", "as": "time"}], "$schema": "https://vega.github.io/schema/vega-lite/v4.0.0.json"}, {"mode": "vega-lite"});
</script>
</div>

        
    
        
    
        
    
        
    
        
    

</div>

</div>
</div>

</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p><em>By cross-filtering you can observe that delayed flights are more likely to depart at later hours. This phenomenon is familiar to frequent fliers: a delay can propagate through the day, affecting subsequent travel by that plane. For the best odds of an on-time arrival, book an early flight!</em></p>
<p>The combination of multiple views and interactive selections can enable valuable forms of multi-dimensional reasoning, turning even basic histograms into powerful input devices for asking questions of a dataset!</p>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h2 id="Summary">Summary<a class="anchor-link" href="#Summary">&#182;</a></h2>
</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<p>For more information about the supported interaction options in Altair, please consult the <a href="https://altair-viz.github.io/user_guide/interactions.html">Altair interactive selection documentation</a>. For details about customizing event handlers, for example to compose multiple interaction techniques or support touch-based input on mobile devices, see the <a href="https://vega.github.io/vega-lite/docs/selection.html">Vega-Lite selection documentation</a>.</p>
<p>Interested in learning more?</p>
<ul>
<li>The <em>selection</em> abstraction was introduced in the paper <a href="http://idl.cs.washington.edu/papers/vega-lite/">Vega-Lite: A Grammar of Interactive Graphics</a>, by Satyanarayan, Moritz, Wongsuphasawat, &amp; Heer.</li>
<li>The PRIM-9 system (for projection, rotation, isolation, and masking in up to 9 dimensions) is one of the earliest interactive visualization tools, built in the early 1970s by Fisherkeller, Tukey, &amp; Friedman. <a href="http://stat-graphics.org/movies/prim9.html">A retro demo video survives!</a></li>
<li>The concept of brushing &amp; linking was crystallized by Becker, Cleveland, &amp; Wilks in their 1987 article <a href="https://scholar.google.com/scholar?cluster=14817303117298653693">Dynamic Graphics for Data Analysis</a>.</li>
<li>For a comprehensive summary of interaction techniques for visualization, see <a href="https://queue.acm.org/detail.cfm?id=2146416">Interactive Dynamics for Visual Analysis</a> by Heer &amp; Shneiderman.</li>
<li>Finally, for a treatise on what makes interaction effective, read the classic <a href="https://scholar.google.com/scholar?cluster=15702972136892195211">Direct Manipulation Interfaces</a> paper by Hutchins, Hollan, &amp; Norman.</li>
</ul>

</div>
</div>
</div>
<div class="cell border-box-sizing text_cell rendered"><div class="prompt input_prompt">
</div><div class="inner_cell">
<div class="text_cell_render border-box-sizing rendered_html">
<h4 id="Appendix:-On-The-Representation-of-Time">Appendix: On The Representation of Time<a class="anchor-link" href="#Appendix:-On-The-Representation-of-Time">&#182;</a></h4><p>Earlier we observed a small bump in the number of movies in either 1969 and 1970. Where does that bump come from? And why 1969 <em>or</em> 1970? The answer stems from a combination of missing data and how your computer represents time.</p>
<p>Internally, dates and times are represented relative to the <a href="https://en.wikipedia.org/wiki/Unix_time">UNIX epoch</a>, in which time "zero" corresponds to the stroke of midnight on January 1, 1970 in <a href="https://en.wikipedia.org/wiki/Coordinated_Universal_Time">UTC time</a>, which runs along the <a href="https://en.wikipedia.org/wiki/Prime_meridian">prime meridian</a>. It turns out there are a few movies with missing (<code>null</code>) release dates. Those <code>null</code> values get interpreted as time <code>0</code>, and thus map to January 1, 1970 in UTC time. If you live in the Americas &ndash; and thus in "earlier" time zones &ndash; this precise point in time corresponds to an earlier hour on December 31, 1969 in your local time zone. On the other hand, if you live near or east of the prime meridian, the date in your local time zone will be January 1, 1970.</p>
<p>The takeaway? Always be skeptical of your data, and be mindful that how data is represented (whether as date times, or floating point numbers, or latitudes and longitudes, <em>etc.</em>) can sometimes lead to artifacts that impact analysis!</p>

</div>
</div>
</div>
 

