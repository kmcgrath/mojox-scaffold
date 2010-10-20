package Mojolicious::Command::Generate::Resource;

use strict;
use warnings;

use base 'Mojo::Command';

use Mojo::ByteStream;


__PACKAGE__->attr(description => <<'EOF');
Generate a resource
EOF
__PACKAGE__->attr(usage => <<"EOF");
usage: $0 generate resource [APP_NAME RESOURCE_NAME]
EOF


### mojolicious generate resource MyApp resource_name
sub run {
    my $self     = shift;
    my $app_name = shift || die 'no app name passed';
    my $res_name = shift || die 'no resource name passed';


    # Create base paths
    my $ctrl_base = 'lib/'.$app_name;
    my $tmpl_base = 'templates';


    # Make sure controller path exists
    unless ( -e $ctrl_base ){
        die 'Controller path '.$ctrl_base.' not found! Make sure that you switch to the directory where your application is located before running "mojolicious generate resource"!';
    }


    # Make sure template path exists
    unless ( -e $tmpl_base ){
        die 'Template path '.$tmpl_base.' not found! Make sure that you switch to the directory where your application is located before running "mojolicious generate resource"!';
    }


    # Create controller path
    my $res_class = Mojo::ByteStream->new($res_name)->camelize->to_string;
    my $ctrl_sub_path = $self->class_to_path($res_class);
    my $ctrl_path = $ctrl_base.'/'.$ctrl_sub_path;


    # Create template path
    my $tmpl_sub_path = join('/', split(/-/, $res_name) );
    my $tmpl_path = $tmpl_base.'/'.$tmpl_sub_path;


    # Create layout path
    my $layout_path = 'templates/layouts';


    # Make sure template path does not already exists
    if ( -e $tmpl_path ){
        die 'Template path '.$tmpl_path.' already exists. Resource could NOT be created!';
    }

    # Make sure controller file does not already exists
    if ( -e $ctrl_path ){
        die 'Controller file '.$ctrl_path.' already exists. Resource could NOT be created!';
    }

    # Change tags
    $self->renderer->line_start('%%');
    $self->renderer->tag_start('<%%');
    $self->renderer->tag_end('%%>');


    # Create a controller file
    $self->render_to_rel_file('controller', $ctrl_path, $app_name, $res_class, $res_name);

    # Create template files
    $self->render_to_rel_file('resourceful_layout', $layout_path."/resourceful_layout.html.ep", $res_name);
    $self->render_to_rel_file('index',       $tmpl_path."/index.html.ep", $res_name);
    $self->render_to_rel_file('show',        $tmpl_path."/show.html.ep");
    $self->render_to_rel_file('create_form', $tmpl_path."/create_form.html.ep", $res_name);
    $self->render_to_rel_file('update_form', $tmpl_path."/update_form.html.ep", $res_name);
    $self->render_to_rel_file('update_form', $tmpl_path."/update_form.html.ep", $res_name);

}

1;
__DATA__
@@ index
%% my $res_name = shift;
% layout 'resourceful_layout', title => 'Index';
Template for displaying a list of resource items<br />
<%= link_to 'Index' => '<%%= $res_name %%>_index' %>
<%= link_to 'New'   => '<%%= $res_name %%>_create_form' %>


@@ show
% layout 'resourceful_layout', title => 'Show';
Template for displaying a single resource item


@@ create_form
%% my $res_name = shift;
% layout 'resourceful_layout', title => 'Create Form';
Template for displaying a form that allows to create a new resource item
<%= form_for '<%%= $res_name %%>_create', method => 'post' => begin %>
    Text field 1 <%= text_field 'foo', value => '' %><br />
    Text field 2 <%= text_field 'bar', value => '' %><br />
    <%= submit_button 'Submit' %>
<% end %>
<br />
<%= link_to 'Index' => '<%%= $res_name %%>_index' %>
<%= link_to 'New'   => '<%%= $res_name %%>_create_form' %>


@@ update_form
%% my $res_name = shift;
% layout 'resourceful_layout', title => 'Update Form';
Template for displaying a form that allows to edit an existing resource item
<%= form_for '<%%= $res_name %%>_update', method => 'post' => begin %>
    Text field 1 <%= text_field 'foo', value => '' %><br />
    Text field 2 <%= text_field 'bar', value => '' %><br />
    <%= submit_button 'Submit' %>
    <!-- DO NOT REMOVE HIDDEN FIELD, NEEDED TO TRANSFORM POST TO PUT -->
    <%= hidden_field '_method' => 'put' %><br />
<% end %>
<br />
<%= link_to 'Index' => '<%%= $res_name %%>_index' %>
<%= link_to 'New'   => '<%%= $res_name %%>_create_form' %>


@@ resourceful_layout
<!doctype html><html>
    <head><title><%= $title %></title></head>
    <body><%= content %></body>
</html>


@@ controller
%% my $name = shift;
%% my $resource_camelized = shift;
%% my $res_name = shift;
package <%%= $name %%>::<%%= $resource_camelized %%>;

use strict;
use warnings;

use base 'Mojolicious::Controller';


sub index {
    my $self = shift;
    # Read all resource items from a database and save them in the stash
    # to make them available in the template index.html.ep
}


sub show {
    my $self = shift;
    # Read existing data from a database using
    # $self->stash('id')
    # and save it to the stash to make it available in the template
    # show.html.ep
}


sub create_form {
    my $self = shift;
}


sub update_form {
    my $self = shift;
    # Read existing data for the resource item from a database using
    # $self->stash('id')
    # and save it to the stash to
    # make it available in the template update_form.html.ep
}


sub create {
    my $self = shift;
    # fetch the newly created id
    # $id = ...;
    # and redirect to "show" in order to display the created resource
    # $self->redirect_to('<%%=$res_name%%>_show', id => $id );
    $self->render_text('create: save data and redirect');
}


sub update {
    my $self = shift;
    # redirect to "show" in order to display the updated resource
    # $self->redirect_to('<%%=$res_name%%>_show', id => $self->stash('id') );
    $self->render_text('update: save data and redirect');
}


sub delete {
    my $self = shift;
}

1;
__END__
